class Mailshot
  class SendToAudienceSegment
    include Mandate

    queue_as :background

    initialize_with :mailshot, :audience_type, :audience_slug, :limit, :offset

    # TOOD: This is where we can add throttling to check how many
    # mails have been sent today and reschedule ourselves for the next
    # day if we've hit a limit
    def call
      @ar_relation, @user_extractor = mailshot.audience_for(audience_type, audience_slug)

      send_to_segment!

      # If we had some records, schedule some more. Once this is zero,
      # we can safely finish the job.
      schedule_next_segment! if records.length.positive?
    end

    private
    attr_reader :ar_relation, :user_extractor

    def send_to_segment!
      records.each do |record|
        user = user_extractor.(record)
        next unless user

        User::Mailshot::Send.(user, mailshot)
      end
    end

    def schedule_next_segment!
      Mailshot::SendToAudienceSegment.defer(
        mailshot, audience_type, audience_slug, limit, offset + limit,
        wait: 5.seconds
      )
    end

    memoize
    def records
      ar_relation.offset(offset).limit(limit).to_a
    end
  end
end
