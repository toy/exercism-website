require "test_helper"

class Exercise::Representation::SearchTest < ActiveSupport::TestCase
  test "no options returns everything" do
    representation_1 = create :exercise_representation
    representation_2 = create :exercise_representation

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.()
  end

  test "filter: criteria" do
    exercise_1 = create :practice_exercise, slug: 'anagram', title: 'Annie'
    exercise_2 = create :practice_exercise, slug: 'another', title: 'Another'
    exercise_3 = create :practice_exercise, slug: 'leap', title: 'Frog'
    representation_1 = create :exercise_representation, exercise: exercise_1
    representation_2 = create :exercise_representation, exercise: exercise_2
    representation_3 = create :exercise_representation, exercise: exercise_3

    assert_equal [representation_1, representation_2, representation_3], Exercise::Representation::Search.(criteria: 'a')
    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(criteria: 'an')
    assert_equal [representation_3], Exercise::Representation::Search.(criteria: 'leap')
    assert_equal [representation_3], Exercise::Representation::Search.(criteria: 'frog')
  end

  test "filter: status" do
    representation_1 = create :exercise_representation, feedback_type: nil
    representation_2 = create :exercise_representation, feedback_type: :actionable
    representation_3 = create :exercise_representation, feedback_type: :essential

    assert_equal [representation_1], Exercise::Representation::Search.(status: :feedback_needed)
    assert_equal [representation_2, representation_3], Exercise::Representation::Search.(status: :feedback_submitted)
  end

  test "filter: user" do
    user_1 = create :user
    user_2 = create :user
    user_3 = create :user
    representation_1 = create :exercise_representation, feedback_author: user_1
    representation_2 = create :exercise_representation, feedback_author: user_2, feedback_editor: user_1
    representation_3 = create :exercise_representation, feedback_editor: user_3

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(user: user_1)
    assert_equal [representation_2], Exercise::Representation::Search.(user: user_2)
    assert_equal [representation_3], Exercise::Representation::Search.(user: user_3)
  end

  test "filter: track" do
    track_1 = create :track, :random_slug
    track_2 = create :track, :random_slug
    exercise_1 = create :practice_exercise, track: track_1
    exercise_2 = create :practice_exercise, track: track_2
    representation_1 = create :exercise_representation, exercise: exercise_1
    representation_2 = create :exercise_representation, exercise: exercise_1
    representation_3 = create :exercise_representation, exercise: exercise_2

    assert_equal [representation_1, representation_2], Exercise::Representation::Search.(track: track_1)
    assert_equal [representation_3], Exercise::Representation::Search.(track: track_2)
    assert_equal [representation_1, representation_2, representation_3], Exercise::Representation::Search.(track: [track_1, track_2])
  end

  test "paginates" do
    25.times { create :exercise_representation }

    first_page = Exercise::Representation::Search.()
    assert_equal 20, first_page.limit_value # Sanity

    assert_equal 20, first_page.length
    assert_equal 1, first_page.current_page
    assert_equal 25, first_page.total_count

    second_page = Exercise::Representation::Search.(page: 2)
    assert_equal 5, second_page.length
    assert_equal 2, second_page.current_page
    assert_equal 25, second_page.total_count
  end
end
