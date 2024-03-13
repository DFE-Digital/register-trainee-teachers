# ITT reform and training routes

## Background
The ITT reform programme stipulated that there will be only three routes into
teaching (excluding early years and iQTS). These three new routes are:

The following existing routes will be unchanged:

- Early years assessment only
- Early years graduate entry
- Early years graduate employment based
- Early years undergraduate
- International qualified teacher status (iQTS)

The following routes will be replaced:

- Assessment only
- Opt-in (undergrad)
- Provider-led postgrad
- Provider-led undergrad
- School direct fee funded
- School direct salaried
- Postgraduate teaching apprenticeship

by:

- Postgraduate fee funded
- Postgraduate salaried
- Undergraduate fee funded

The mapping from old to new training route will (presumably) need to take into
account the funding attributes:

- applying_for_bursary
- applying_for_grant
- applying_for_scholarship

## Findings

- Mappings from HESA will be manageable I think. We will have to rely on the
  funding info that we get from HESA alongside the training route because I
  don't think the HESA training route itself is enough to determine the correct
  route on our side I think.
- For the API the main issue I foresee is the reverse mapping from our new
  training routes to HESA training routes (because we have to output this data
  now as well as input it).
- I can't find any references to training routes in the DfE Reference Data gem.

## Question
- What are we doing with legacy data that links to existing routes that we are
  getting rid of? Should the changes apply only from a point in time leaving
  all the old values in place? I'm guessing this will apply to all trainees
  register for course from the 2024-25 recruitment cycle? In which case we need
  to keep all the existing routes, just stop giving them as an option? Or do we
  need to convert all the legacy data to use the new slimmed down set of
  routes?
- What will be the mechanism for switching over to the new routes? Do we simply
  have a cutoff date after which all trainees will get the new routes? Or is it
  done on a by course start date say? The later might be tricky because we have
  to select a route before a course when registering manually. Could we just
  use a feature flag?
- Can we map old to new routes using the old route plus funding attributes
  (listed above) or is there more to it than that?
- Do we need separate boolean attributes for _Opt-in (undergrad)_ and
  _Assessment only_?
