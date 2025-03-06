# Disaster recovery

Refer to the [platform disaster recovery documentation](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/disaster-recovery.md) for the full details.


```mermaid
flowchart TB
    A[🔴 Failing App Service] --> B[🟡 Maintenance Page on register-temp.test.teacherservices.cloud]
    B --> C[🟡 Maintenance Page on staging.register-trainee-teachers.service.gov.uk]

    subgraph right_flow[ ]
        direction LR
        style right_flow fill:#fff9c4,stroke:#fbc02d,stroke-width:2px
        C --> D[🟢 Replacement App Service on register-temp.test.teacherservices.cloud]
        D --> T[🔵 Testing on register-temp.test.teacherservices.cloud]
    end

    T --> G[❌ Testing Failed]

    subgraph retry_flow[ ]
        direction TB
        style retry_flow fill:#ffcdd2,stroke:#f44336,stroke-width:2px
        G --> C
    end

    T --> S[🟢 Ready for Switchover]

    subgraph happy[ ]
        direction LR
        style happy fill:#e8f5e9,stroke:#66bb6a,stroke-width:2px
        S --> E[🟢 Replacement App Service on staging.register-trainee-teachers.service.gov.uk]
    end

    subgraph clean_up[ ]
        direction LR
        style clean_up fill:#f3e5f5,stroke:#ab47bc,stroke-width:2px
        E --> F[🟢 Remove Maintenance Page]
        F --> V[🟢 Remove register-temp.test.teacherservices.cloud]
    end

    style A fill:#f44336,stroke:#000,stroke-width:2px
    style B fill:#ffeb3b,stroke:#000,stroke-width:2px
    style C fill:#ffeb3b,stroke:#000,stroke-width:2px
    style D fill:#66bb6a,stroke:#000,stroke-width:2px
    style T fill:#2196f3,stroke:#000,stroke-width:2px
    style S fill:#66bb6a,stroke:#000,stroke-width:2px
    style E fill:#66bb6a,stroke:#000,stroke-width:2px
    style F fill:#ffeb3b,stroke:#000,stroke-width:2px
    style V fill:#ffeb3b,stroke:#000,stroke-width:2px
```

## Scenario one

The below steps was (completed 06/03/2025)

### 📝 Start the incident process and inform stakeholders
  - **What**: Incident response and stakeholder notification
  - **Why**: To ensure timely and effective communication and response to the incident
  - **How**: Follow the incident playbook and contact stakeholders as described
  - **Note**:
    - We skipping the incident bot.

### 🚫 Freeze pipeline by updating branch protection rules
  - **What**: Freeze pipeline to prevent changes
  - **Why**: To prevent further disruptions or changes during the incident response
  - **How**: Update branch protection rules to require 6 PR approvers
  - **Note**:
    - [Branch protection rule](https://github.com/DFE-Digital/register-trainee-teachers/settings/branch_protection_rules/17303670)

### 🛠️ Enable maintenance mode by running the Enable maintenance workflow
  - **What**: Enable maintenance mode
  - **Why**: To notify users of the issue and prevent further interactions with the affected system
  - **How**: Run the Enable maintenance workflow
  - **Note**:
    - [Set maintenance mode](https://github.com/DFE-Digital/register-trainee-teachers/actions/workflows/maintenance.yml)

### 📈 Recreate the lost postgres database server by running the deploy workflow
  - **What**: Recreate the lost postgres database server
  - **Why**: To restore the database server and its functionality
  - **How**: Run the deploy workflow with updated terraform configuration
  - **Note**:
    - See [Maintenance page](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/maintenance-page.md)
    - https://github.com/DFE-Digital/register-trainee-teachers/compare/xxxx-dr-send_traffic_to_maintenance_page-true?expand=1
    - Turn on `send_traffic_to_maintenance_page`
        - ```bash
          git switch -c xxxx-dr-send_traffic_to_maintenance_page-true
          ```
          - change https://github.com/DFE-Digital/register-trainee-teachers/blob/66fd4a6c8bc9185ab01746cb6a8f5de026c47716/terraform/aks/workspace-variables/staging.tfvars.json#L48
              - from
                ```txt
                 "send_traffic_to_maintenance_page": false
                ```
                to
                ```txt
                 "send_traffic_to_maintenance_page": true
                ```
    - [Deploy](https://github.com/DFE-Digital/register-trainee-teachers/actions/workflows/deploy.yml)
        - Select the branch `xxxx-dr-send_traffic_to_maintenance_page-true`
### 💻 Restore data from previous backup in Azure storage by running the Restore database from Azure storage workflow
  - **What**: Restore data from previous backup
  - **Why**: To recover lost data and restore system functionality
  - **How**: Run the Restore database from Azure storage workflow
  - **Note**:
    - [Restore database from Azure storage](https://github.com/DFE-Digital/register-trainee-teachers/actions/workflows/postgres-restore.yml)

### 📊 Validate the app by confirming it's working and can see the restored data
  - **What**: Validate the app
  - **Why**: To ensure the app is functioning correctly with the restored data
  - **How**: Confirm the app is working and can see the restored data on the temporary ingress URL
  - **Note**:
    - Non technicals members
      - Confirm there is nothing out odd
        - via service
          - `https://register-temp.test.teacherservices.cloud/`
          - Login then drill down
            - as a provider
              - to a registered trainee
              - to a draft trainee
            - as a support agent
              - to a user
    - Technicals members
      - Confirm there is nothing out odd
        - /sha
          - `https://register-temp.test.teacherservices.cloud/sha`
        - /healthcheck
          - `https://register-temp.test.teacherservices.cloud/healthcheck`
        - Blazer
          - `https://register-temp.test.teacherservices.cloud/system-admin/blazer`
        - sidekiq
          - `https://register-temp.test.teacherservices.cloud/system-admin/sidekiq`
        - /api/v1.0-pre/info
          - `https://register-temp.test.teacherservices.cloud/api/v1.0-pre/info`
          -  ```bash
             az login --use-device-code
             ```
                - We got to login on microsoft x 2
          -  ```bash
             make staging console
             ```
                - There is also
                  ```bash
                  make staging ssh
                  ```
          - Check without `token`
            ```bash
            curl -H "Accept: application/json" -X GET \
            https://register-temp.test.teacherservices.cloud/api/v1.0-pre/info
            ```

            Expect to see

            ```json
            {"error":"Unauthorized"}
            ```
          - Check with `token`
            - Create `token`
              ```ruby
              # https://register-temp.test.teacherservices.cloud/system-admin/providers/93
              # https://register-temp.test.teacherservices.cloud/system-admin/providers/{provider_id_to_replace}
              provider_id_to_replace = 93
              existing_provider = Provider.find(provider_id_to_replace)
              if AuthenticationToken.where(provider: existing_provider).count.zero?
                token = AuthenticationToken.create_with_random_token(provider: existing_provider)

                puts "Token: `#{token}`"
              end
              ```

              Expect to see
              ``` ini
              Token: `3endbbbe01d3af15e82e417`

              ```

            - Use `token`
              ```bash
              curl -X GET \
              https://register-temp.test.teacherservices.cloud/api/v1.0-pre/info \
              -H 'Authorization: Bearer 3bbbe01d3af15e82e417'
              ```

              Expect to see
              ```json
              {"status":"ok","version":{"requested":"v1.0-pre","latest":"v1.0-pre"}}
              ```
          - Check without a valid `token`
            - Remove existing `token`
              ```ruby
                provider_id_to_replace = 93
                existing_provider = Provider.find(provider_id_to_replace)
                AuthenticationToken.where(provider: existing_provider).find_each(&:delete)
              ```

            - Use invalid `token`
              ```bash
              curl -X GET \
              https://register-temp.test.teacherservices.cloud/api/v1.0-pre/info \
              -H 'Authorization: Bearer 3bbbe01d3af15e82e417'
              ```

              Expect to see

              ```json
              {"error":"Unauthorized"}
              ```

### 🛠️ Disable maintenance mode by running the Disable maintenance workflow
  - **What**: Disable maintenance mode
  - **Why**: To allow users to interact with the system again
  - **How**: Run the Disable maintenance workflow
  - **Note**:
    - [Set maintenance mode](https://github.com/DFE-Digital/register-trainee-teachers/actions/workflows/maintenance.yml)

### 🚀 Unfreeze pipeline by updating branch protection rules back to normal
  - **What**: Unfreeze pipeline
  - **Why**: To allow development and changes to resume
  - **How**: Update branch protection rules back to normal (1 PR approver)
  - **Note**:
    - [Branch protection rule](https://github.com/DFE-Digital/register-trainee-teachers/settings/branch_protection_rules/17303670)
