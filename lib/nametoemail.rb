require 'json'

class NameToEmail
  def initialize(input, namefield, presetdomain, chosendomain, urlfield, formattype)
    @input = JSON.parse(input)
    @namefield = namefield
    @urlfield = urlfield
    @presetdomain = presetdomain
    @chosendomain = chosendomain
    @emaillist = Array.new
    @formattype = formattype
  end

  # Get emails of all formats
  def genemails
    nametrack = Array.new

    @input.each do |i|
      # Parse domain
      if @presetdomain == false
        domain = parseurl(i[@urlfield])
      else
        domain = @chosendomain
      end

      if i[@namefield] && domain
        name = parsename(i[@namefield])
        
        # Check if combination already exists
        if name && domain
          namedomain = name[0] + name[1] + domain
          if !(nametrack.include? namedomain)
            nametrack.push(namedomain)

            if @formattype == "all"
              itememails = tryallformats(name, domain)
            else
              itememails = tryoneformat(name, domain, @formattype)
            end

            i["emails"] = itememails
          end
        end
      end
    end
  end

  # Get emails in all formats
  def tryallformats(name, domain)
    itememails = Array.new

    # Generate emails                                                                                                     
    itememails.push(firstlastdot(name[0], name[1], domain))
    itememails.push(firstinitiallastname(name[0], name[1], domain))
    itememails.push(firstunderscorelast(name[0], name[1], domain))
    itememails.push(lastnamefirstinitial(name[0], name[1], domain))
    itememails.push(justlast(name[1], domain))
    itememails.each do |e|
      @emaillist.push(e)
    end

    return itememails
  end

  # Gets all emails of one format
  def tryoneformat(name, domain, format)
    email = ""

    case format
    when "firstlastdot" then email = firstlastdot(name[0], name[1], domain)
    when "firstinitiallastname" then email = firstinitiallastname(name[0], name[1], domain)
    when "firstunderscorelast" then email = firstunderscorelast(name[0], name[1], domain)
    when "lastnamefirstinitial" then email = lastnamefirstinitial(name[0], name[1], domain)
    when "justlast" then email = justlast(name[1], domain)
    else email = nil
    end

    @emaillist.push(email)
    return email
  end

  # Emails of the form lastname@domain
  def justlast(lastname, domain)
    return lastname + "@" + domain
  end

  # Emails of form firstname.lastname@domain
  def firstlastdot(firstname, lastname, domain)
    return firstname + "." + lastname + "@" + domain
  end

  # Emails of the form lastnamefirstinitial
  def lastnamefirstinitial(firstname, lastname, domain)
    return lastname + firstname[0] + "@" + domain
  end

  # Emails of the form firstinitiallastname@domain
  def firstinitiallastname(firstname, lastname, domain)
    return firstname[0] + lastname + "@" + domain
  end

  # Emails of the form firstname_lastname@domain
  def firstunderscorelast(firstname, lastname, domain)
    return firstname + "_" + lastname + "@" + domain
  end

  # Parse url to get just the domain
  def parseurl(url)
    parsed = url.gsub("http://", "").gsub("www.", "")
    split = parsed.split("/")
    if split[0]
      return split[0]
    end
  end

  # Gets first and last name and removes certain characters
  def parsename(name)
    splitn = name.split(" ")
    first = splitn.first.gsub("'", "").gsub("-", "").gsub(".", "")
    last = splitn.last.gsub("'", "").gsub("-", "").gsub(".", "")
    narray = [first.downcase, last.downcase]
    return narray
  end

  # Get list of just emails
  def emaillist
    return JSON.pretty_generate(@emaillist)
  end

  # Get JSON with emails appended
  def jsonwithemails
    return JSON.pretty_generate(@input)
  end
end
