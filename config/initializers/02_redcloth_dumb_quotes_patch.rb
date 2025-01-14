# RedCloth's default implementation uses HTML entites for "smart quotes" in
# various places. The bug tracker deals with code samples in tickets sometimes
# and those aren't always properly escaped or flagged, so we want to avoid
# breaking quotes. Smart quotes are mostly just for aesthetics, after all.
#
# There's no official option/setting for this, so we patch things instead.
#
require 'redcloth'

unless (RedCloth::Formatters::HTML rescue nil).is_a?(Module)
  raise "RedCloth patch in 02_redcloth_dumb_quotes_patch.rb is out of date"
end

module RedCloth::Formatters::HTML
  def quote1(opts)
    "'#{opts[:text]}'"
  end

  def quote2(opts)
    "\"#{opts[:text]}\""
  end
end
