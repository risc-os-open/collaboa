module GravatarHelper

  # Generate the image tag for a change author's Gravatar based on the given
  # e-mail address. Optionally provide a pixel size (the length of any side of
  # the square icon).
  #
  def gravatar_tag(email, size = 32)
    return '' if email.blank?

    image_tag(
      "https://www.gravatar.com/avatar.php?gravatar_id=#{Digest::SHA256.hexdigest(email)}&size=#{size}",
      size:  "#{size}x#{size}",
      class: 'gravatar'
    )
  end

end
