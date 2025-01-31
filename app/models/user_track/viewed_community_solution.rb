class UserTrack::ViewedCommunitySolution < ApplicationRecord
  belongs_to :user
  belongs_to :track
  belongs_to :solution

  has_one :user_track, # rubocop:disable Rails/HasManyOrHasOneDependent
    ->(vcs) { where(track_id: vcs.track_id) },
    foreign_key: :user_id,
    primary_key: :user_id,
    inverse_of: :viewed_community_solutions
end
