module ActiveModel
  module Dirty
    def can_change_primary_key?
      true
    end

    def primary_key_changed?
      !!changed.detect { |key| ids_hash.keys.include?(key.to_s) }
    end

    def primary_key_was
      ids_hash.keys.inject(Hash.new) do |result, attribute_name|
        result[attribute_name] = attribute_was(attribute_name.to_s)
        result
      end
    end
    alias_method :ids_hash_was, :primary_key_was

    alias_method :old_attribute_was, :attribute_was
    def attribute_was(attr)
      if Array === attr
        attr.map {|attr| old_attribute_was(attr)}
      else
        old_attribute_was(attr)
      end
    end
  end
end
