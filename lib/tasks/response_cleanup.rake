task response_cleanup: :environment do
  # give new uuids to duplicates (allows unique indexing) and delete (soft) them
  grouped_responses = Response.with_deleted.group_by {|response| response.uuid}
  grouped_responses.values.each do |duplicates|
    duplicates.shift
    duplicates.each_with_index { |dup, index|
      dup.uuid = "#{dup.uuid}_dup_#{index}"
      dup.save!
      dup.destroy
    }
  end
end
