module ActiveRecord
  module AutosaveAssociation
    private

    def save_has_one_association(reflection)
      association = association_instance_get(reflection.name)
      record      = association && association.load_target
      if record && !record.destroyed?
        autosave = reflection.options[:autosave]

        if autosave && record.marked_for_destruction?
          record.destroy
        else
          # CPK: Use existing functions to get the current value of the key
          #key = reflection.options[:primary_key] ? send(reflection.options[:primary_key]) : id
          key = self[reflection.active_record_primary_key]
          if autosave != false && (new_record? || record.new_record? || record[reflection.foreign_key] != key || autosave)
            unless reflection.through_reflection
              # CPK: Use the existing function to set the key
              #record[reflection.foreign_key] = key
              association.set_owner_attributes(record)
            end

            saved = record.save(:validate => !autosave)
            raise ActiveRecord::Rollback if !saved && autosave
            saved
          end
        end
      end
    end

    # Saves the associated record if it's new or <tt>:autosave</tt> is enabled.
    #
    # In addition, it will destroy the association if it was marked for destruction.
    def save_belongs_to_association(reflection)
      association = association_instance_get(reflection.name)
      record      = association && association.load_target
      if record && !record.destroyed?
        autosave = reflection.options[:autosave]

        if autosave && record.marked_for_destruction?
          self[reflection.foreign_key] = nil
          record.destroy
        elsif autosave != false
          saved = record.save(:validate => !autosave) if record.new_record? || (autosave && record.changed_for_autosave?)

          if association.updated?
            # CPK: Use the existing function to set the key
            #association_id = record.send(reflection.options[:primary_key] || :id)
            #self[reflection.foreign_key] = association_id
            association.send(:replace_keys, record)
            association.loaded!
          end

          saved if autosave
        end
      end
    end
  end
end
