class String
  def sp_titleize_url
    self.titlecase.tr(' ', '-').gsub('.Fr', '.fr')
  end
end
