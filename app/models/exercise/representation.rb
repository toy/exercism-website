class Exercise::Representation < ApplicationRecord
  serialize :mapping, JSON
  has_markdown_field :feedback

  belongs_to :exercise
  belongs_to :source_submission, class_name: "Submission"
  belongs_to :feedback_author, optional: true, class_name: "User"
  belongs_to :feedback_editor, optional: true, class_name: "User"
  has_one :track, through: :exercise
  has_one :solution, through: :source_submission

  enum feedback_type: { essential: 0, actionable: 1, non_actionable: 2 }, _prefix: :feedback

  has_many :submission_representations,
    ->(er) { joins(:solution).where("solutions.exercise_id": er.exercise_id) },
    class_name: "Submission::Representation",
    foreign_key: :ast_digest,
    primary_key: :ast_digest,
    inverse_of: :exercise_representation

  scope :without_feedback, -> { where(feedback_type: nil) }
  scope :with_feedback, -> { where.not(feedback_type: nil) }
  scope :mentored_by, ->(mentor) { joins(:solution).where(solutions: mentor.mentor_discussion_solutions) }
  scope :track_mentored_by, ->(mentor) { joins(:exercise).where(exercises: { track: mentor.mentored_tracks }) }
  scope :edited_by, ->(mentor) { where(feedback_author: mentor).or(where(feedback_editor: mentor)) }
  scope :for_track, ->(track) { joins(:exercise).where(exercises: { track: }) }

  def num_times_used
    submission_representations.count
  end

  def has_essential_feedback?
    has_feedback? && feedback_essential?
  end

  def has_actionable_feedback?
    has_feedback? && feedback_actionable?
  end

  def has_non_actionable_feedback?
    has_feedback? && feedback_non_actionable?
  end

  def has_feedback?
    [feedback_markdown, feedback_author_id, feedback_type].all?(&:present?)
  end
end
