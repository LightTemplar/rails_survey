class IndexedScheme < ScoringScheme
  def score(obj, ref_score=nil)
    return nil if obj.response.blank? || ref_option_index_raw_score.blank?
    if reference_qid && ref_score
        references = ref_score.response.split(',')
        if references.size == 1
          ref_hash = ref_option_index_raw_score[references[0]]
          return ref_hash[obj.response.strip] if ref_hash #TODO Why is ref_hash nil?
        else
          #TODO What to do?
        end
    else
      ref_option_index_raw_score[obj.response]
    end
  end
end