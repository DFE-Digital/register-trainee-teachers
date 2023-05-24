# frozen_string_literal: true

class DeferIncorrectlyAwardedTrainees5455 < ActiveRecord::Migration[7.0]
  def up
    %w[zzkoY74NYqNrWE6xbpfW1xBt
       TEvJH8EbaiWqFA6RSTFF4Xd2
       5df1GMu4eH21i17SzpfdUVdZ
       o4V15CNeomt2C76SMpzyNuCq
       nkg4tsXnWETGoEG8jBi3epPP
       PSKoFkYk5gith28acqMT8nwr
       XHv2viHBUkW5PxbmxHzxyLnz
       NkmX2GKUMGkvH4yF66FZcADt
       1UjJdkzFVJcjChypGBCd3vVR
       kyKHpSxyUKCvFgB5dgwBxf9o
       hrqwTCfEQdyt6zHdpaLgXq4e
       s7Ta1ofGMJ8FwaQpLWX5Keg5
       uN9BVsDGFsVp7vjzzAU4FEZi
       r79aCYnBNo1UEv1XqRC7o62j
       mRJQAbLiCqZ8anYUgf1zgsc1
       1kkYdKCUTayM2q2LS3TtEpE1
       Dvs6jB1LKE3S5eaJJ6R1m2mS
       PZavC9q52Bih8phNWSWQhH6E
       KzWLXfqCtm6bf2Kphbm1Um3P
       zmk6YtXGpCcKx9yaaTdopQx6
       NcAx13MtEpB4C7oCQadyhsjd
       g2yBb2H36G4MJYMUAyPXLFkA
       pVc8ujWtQdBEakifYSFVCTbR
       jqmWhdDoFiBAnshR6ks1qCb7
       GoR5Jyum3tV2hPooozYohWjc
       ngDX7p3oqUTygU8Ht8mJNadQ
       LeaeXHNwNZTB4a9pkzE41ANY
       nz9JhaDKsgkiXNf3aSPdRW6q
       Q3cC4X5hLqeRKuBp1CR9i7MT
       FHPGb99z2UdDkAMiiUaGFA75
       N594cASGxNj6FT484k3HkKjd
       XWzv3ezfDcPdaxxmH5HDP6o5
       wUJkd9vf3zCfy6z86KrBRLxC].each do |slug|
      Trainee.find_by(slug:)&.update!(state: :deferred, audit_comment: "Corrected state as per card 5455")
    end
  end
end
