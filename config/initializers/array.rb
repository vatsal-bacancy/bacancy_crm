class Array
  def reject_blank
    self.reject{|e| e.blank?}
  end
end
