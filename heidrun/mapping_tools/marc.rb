module MappingTools
  ##
  # Static methods for evaluations and assignments that can be shared between
  # mappings of MARC providers.
  #
  module MARC
    require_relative 'marc/genre'
    require_relative 'marc/dctype'

    module_function

    ##
    # Given options representing leader and controlfield values, return an
    # array of applicable genre (edm:hasType) controlled-vocabulary terms
    #
    # Options are as follows, and are all Strings:
    #   - leader:  value of MARC 'leader' element
    #   - cf_007:  value of MARC 'controlfield' with 'tag' attribute '007'
    #   - cf_008:  value of MARC 'controlfield' with 'tag' attribute '008'
    #   - cf_970a:  TODO
    #
    # @param opts [Hash] Options, as outlined above
    # @return [Array]
    def genre(opts)
      genres = []
      args = [genres, opts]
      # TODO: insert handling of optional cf_970a for Hathi, as the first
      # evaluation.
      Genre.assign_language(*args) || Genre.assign_musical_score(*args) \
        || Genre.assign_manuscript(*args) || Genre.assign_maps(*args) \
        || Genre.assign_projected(*args) || Genre.assign_two_d(*args) \
        || Genre.assign_nonmusical_sound(*args) \
        || Genre.assign_musical_sound(*args)
      genres << 'Government Document' if Genre.government_document?(opts[:cf_008])
      genres
    end

    def dctype(opts)
      types = []
      args = [types, opts]
      DCType.assign_337a(*args)
      DCType.assign_text(*args) \
        || DCType.assign_still_and_moving_image(*args) \
        || DCType.assign_sound(*args) || DCType.assign_physical_object(*args) \
        || DCType.assign_collection(*args) \
        || DCType.assign_interactive_rsrc(*args)
      types
    end

    ##
    # Return a lambda suitable for Array#select, that gives the XML element
    # with a particular name and 'tag' attribute.
    #
    # @example
    #   The XML element for control field 007 has a 'name' of 'controlfield'
    #   and a 'tag' of '007', so:
    #     r.node.children
    #      .select(&name_tag_condition('controlfield', '007')).first
    #   gives you the matching element.
    #
    # @param name [String] The element name, without the namespace
    # @param tag  [String] The value of the element's 'tag' attribute
    def name_tag_condition(name, tag)
      lambda { |node| node.name == name && node[:tag] == tag }
    end

    ##
    # Return a lambda suitable for Array#select, that gives the XML element
    # for a datafield's subfield that has a particular code
    #
    # @param name [String] The element name, without the namespace
    # @param code  [String] The value of the element's 'code' attribute
    def subfield_code_condition(code)
      lambda { |node| node.name == 'subfield' && node[:code] == code }
    end

    ##
    # Return an Element for the datafield with the given number (tag), or nil
    #
    # @param r    [Krikri::XmlParser::Value] The record root element
    # @param name [String] The XML element name, without the namespace
    # @param tag  [String] The value of the element's 'tag' attribute
    # @return     [Element] or [nil]
    def select_field(r, name, tag)
      r.node.children
       .select(&name_tag_condition(name, tag)).first
    end

    ##
    # Return an Element for the datafield with the given number (tag)
    #
    # @param r   [Krikri::XmlParser::Value] The record root element
    # @param tag [String] The tag, e.g. '240'
    # @return    [Element] or [nil], per #select_field
    def datafield_el(r, tag)
      select_field(r, 'datafield', tag)
    end

    ##
    # Return the String value of the controlfield with the given number (tag)
    #
    # @param  r   [Krikri::XmlParser::Value] The record root element
    # @param  tag [String]  The tag, e.g. '007'
    # @return     [String]
    # @raise      [NoElementError]  If the controlfield doesn't exist
    def controlfield_value(r, tag)
      select_field(r, 'controlfield', tag).children.first.to_s
    rescue NoMethodError
      raise NoElementError.new "No control field #{tag}"
    end

    ##
    # Return an Element for the MARC leader
    #
    # @param   r [Krikri::XmlParser::Value] The record root element
    # @return    [String]
    # @raise     [NoElementError]  If there is no leader
    def leader_value(r)
      r.node.children.select { |n| n.name == 'leader' }
                     .first.children.first.to_s
    rescue NoMethodError
      raise NoElementError.new "No MARC leader element"
    end

    ##
    # Return the String value of the subfield element with the given code
    #
    # An empty string is returned if the subfield can not be found, so that
    # an empty subfield or a missing subfield can both be detedted with
    # `String#empty?`
    #
    # @param  element [Element] The elemenet, e.g. datafield
    # @param  code    [String]  Code, i.e. its 'tag' attribute
    # @return         [String]  ('' if the subfield can not be found)
    def subfield_value(element, code)
      if !element.nil?
        node = element.children.to_a.select(&subfield_code_condition(code))
        !node.empty? ? node.first.children.to_s : ''
      else
        ''
      end
    end

    ##
    # Whether Control Field 007 indicates Film / Video
    # @param s [String] Control Field 007
    def film_video?(s)
      %w(c d f o).include?(s[1])
    end

    class NoElementError < StandardError; end
  end
end
