build_uri = lambda do |node|
  uri = RDF::URI(node.value)
  uri.scheme = 'https' unless uri.scheme
  return uri if uri.valid?
  []
end

Krikri::Mapper.define(:lc_json, :parser => Krikri::JsonParser) do
  provider class: DPLA::MAP::Agent do
    uri 'http://dp.la/api/contributor/lc'
    label 'Library of Congress'
  end

  dataProvider class: DPLA::MAP::Agent,
               each:  record.field('item', 'repository'),
               as:    :agent do
    providedLabel agent
  end

  isShownAt class: DPLA::MAP::WebResource do
    uri record.field('item', 'url|id').map(&build_uri)
  end

  originalRecord class: DPLA::MAP::WebResource do
    uri record_uri
  end

  preview class: DPLA::MAP::WebResource do
    uri record.field('resources').first_value.field('image').map(&build_uri)
    # can't map mimetypes for dcformat
    # these are grouped under `item`, and/or hidden deep in
    # `resources.files`. There doesn't seem to be a way to chose
    # the right one
  end

  sourceResource class: DPLA::MAP::SourceResource do

    alternative record.field('item')
                 .field('other_title|other_titles|alternate_title')

    collection  class: DPLA::MAP::Collection,
                each:  record.field('item', 'partof'),
                as:    :col do
      uri col.field('uri').map(&build_uri)
      title col.field('title')
    end

    contributor class: DPLA::MAP::Agent,
                each:  record.field('item')
                  .if.field('contributor_names')
                  .else { |item| item.field('contributors').field_names },
                as:    :contributor do
      providedLabel contributor
    end

    creator class: DPLA::MAP::Agent,
            each:  record.field('item')
              .if.field('creator')
              .else { |item| item.field('creators').field_names },
            as:    :creator do
      providedLabel creator
    end

    date class: DPLA::MAP::TimeSpan,
         each:  record.field('item')
           .if.field('date')
           .else { |item| item.field('dates').field_names },
         as:    :date do
      providedLabel date
    end

    description record.field('item', 'description')

    extent record.field('item', 'medium')

    # # Dropping non-DCMI types handled in KriKri::Enrichments::MoveNonDcmiType
    dcformat record.field('item').field('type|genre')
              .else { |item| item.field('format').field_names }

    genre record.field('item').field('type|genre')
           .else { |item| item.field('format').field_names }

    identifier record.field('item', 'id')

    language class: DPLA::MAP::Controlled::Language,
             each:  record.field('item', 'language').field_names,
             as:    :lang do
      providedLabel lang
    end

    spatial class: DPLA::MAP::Place,
            each:  record.field('locations'),
            as: :place do
      providedLabel place.field('properties', 'name')
      exactMatch place.field('properties', 'uris')
                  .first_value.map(&build_uri)

      long place.field('geometry', 'coordinates').first_value
      lat  place.field('geometry', 'coordinates').last_value
    end

    publisher record.field('item', 'created_published')

    relation record.field('item', 'related_items')

    rights record.field('item', 'rights_advisory|rights')

    subject class: DPLA::MAP::Concept,
            each:  record.field('item', 'subject_headings'),
            as:    :subject do
      providedLabel subject
    end

    title record.field('item', 'title')

    # Dropping non-DCMI types handled in KriKri::Enrichments::MoveNonDcmiType
    dctype record.field('item', 'online_format')
  end
end
