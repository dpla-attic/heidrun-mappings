Krikri::Mapper.define(:in_qdc,
                      :parser => Krikri::QdcParser,
                      :parser_args => '//qdc:qualifieddc') do
  provider :class => DPLA::MAP::Agent do
    uri 'http://dp.la/api/contributor/il'
    label 'Illinois Digital Heritage Hub'
  end

  dataProvider :class => DPLA::MAP::Agent do
    providedLabel record.field('dcterms:provenance')
  end

  isShownAt :class => DPLA::MAP::WebResource do
    uri record.field('edm:isShownAt')
  end

  preview :class => DPLA::MAP::WebResource do
    uri record.field('edm:preview')
  end

  originalRecord :class => DPLA::MAP::WebResource do
    uri record_uri
  end

  sourceResource :class => DPLA::MAP::SourceResource do
    alternative record.field('dcterms:alternative')

    collection :class => DPLA::MAP::Collection, :each => record.field('xmlns:header', 'xmlns:setSpec'), :as => :coll do
      title coll
    end

    contributor :class => DPLA::MAP::Agent, :each => record.field('dc:contributor'), :as => :contrib do
      providedLabel contrib
    end

    creator :class => DPLA::MAP::Agent, :each => record.field('dc:creator'), :as => :creator do
      providedLabel creator
    end

    date :class => DPLA::MAP::TimeSpan, :each => record.field('dc:date', 'dcterms:created'), :as => :created do
      providedLabel created
    end

    description record.field('dc:description')

    dcformat record.field('dc:format', 'dcterms:medium')
    
    genre record.field('dc:format', 'dcterms:medium')

    language :class => DPLA::MAP::Controlled::Language, :each => record.field('dc:language'), :as => :lang do
      providedLabel lang
    end

    spatial :class => DPLA::MAP::Place, :each => record.field('dcterms:spatial'), :as => :place do
      providedLabel place
    end

    rights record.fields('dc:rights')

    subject :class => DPLA::MAP::Concept, :each => record.field('dc:subject'), :as => :subject do
      providedLabel subject
    end

    temporal :class => DPLA::MAP::TimeSpan, :each => records.field('dcterms:temporal'), :as => :temp do
      providedLabel temp
    end

    title record.field('dc:title')

    dctype record.field('dc:type')
  end
end
