Krikri::Mapper.define(:tn_mods, :parser => Krikri::ModsParser) do
  provider :class => DPLA::MAP::Agent do
    uri 'http://dp.la/api/contributor/tn'
    label 'Tennessee Digital Library'
  end

  dataProvider :class => DPLA::MAP::Agent do
    providedLabel record.field('mods:recordInfo', 'mods:recordContentSource')
  end

  isShownAt :class => DPLA::MAP::WebResource do
    uri record.field('mods:location', 'mods:url')
         	  .match_attribute(:usage, 'primary display')
              .match_attribute(:access, 'object in context')
  end

  preview :class => DPLA::MAP::WebResource do
    uri record.field('mods:location', 'mods:url')
              .match_attribute(:access, 'preview')
  end

  originalRecord :class => DPLA::MAP::WebResource do
    uri record_uri
  end
#they have a mapping for format and rights in the Web Resource as well...not sure how to implement

  sourceResource :class => DPLA::MAP::SourceResource do
    alternative record.field('mods:titleInfo')
                      .match_attribute(:type, 'alternative')
                      .field('mods:title')

    collection :class => DPLA::MAP::Collection,
               :each => record.field('mods:relatedItem')
               				  .match_attribute(:type, 'host')
               				  .match_attribute(:displayLabel, 'Project')
               				  .field('mods:titleInfo', 'mods:title'),
               :as => :coll do
      title coll
    end

    contributor :class => DPLA::MAP::Agent,
                :each => record.field('mods:name')
                        .select { |name| name['mods:role'].map(&:value).include?('contributor') },
                :as => :contrib do
      providedLabel contrib.field('mods:namePart')
    end
    
    creator :class => DPLA::MAP::Agent,
            :each => record.field('mods:name')
                    .select { |name| name['mods:role'].map(&:value).include?('creator') },
            :as => :creator_role do
      providedLabel creator_role.field('mods:namePart')
    end

    date :class => DPLA::MAP::TimeSpan,
         :each => record.field('mods:originInfo'),
         :as => :created do
      providedLabel created.field('mods:dateCreated')
    end

    description record.field('mods:abstract')

    extent record.field('mods:physicalDescription', 'mods:extent')

    # non-DCMIType values from type will be handled in enrichment
    dcformat record.field('mods:physicalDescription', 'mods:form')

    genre record.field('mods:genre').match_attribute(:authority 'aat')

    identifier record.field('mods:identifier')

    language :class => DPLA::MAP::Controlled::Language,
             :each => record.field('mods:language', 'mods:languageTerm')
             				.match_attribute(:type 'code')
             				.match_attribute(:authority 'iso639-2b'),
             :as => :lang do
      prefLabel lang
    end

    spatial :class => DPLA::MAP::Place,
            :each => record.field('mods:subject', 'mods:geographic'),
            :as => :place do
      providedLabel place
    end
    
    #They have coordinates as well. I wasn't sure if I should add a second spatial mapping or include this in the previous. I decided to add a second. Is that correct?
    spatial :clas => DPLA::MAP::Place,
      		:each => record.field('mods:subject', 'mods:cartographics', 'mods:coordinates'),
      		:as => :lat do
      wgs84_pos:lat lat
    end

    publisher :class => DPLA::MAP::Agent,
              :each => record.field('mods:originInfo'),
              :as => :publisher do
      providedLabel publisher.field('mods:publisher')
    end
    
    #totally a guess as to how to not map properties with certain attributes. for relation
    relation record.field('mods:relatedItem')
    				.reject_attribute(:type 'isReferencedBy')
    				.reject_attribute(:type 'references')
    				.field('mods:titleInfo', 'mods:title')
    
    relation record.field('mods:relatedItem')
    				.reject_attribute(:type 'isReferencedBy')
    				.reject_attribute(:type 'references')
    				.field('mods:titleInfo', 'mods:url')
    				
    isReplacedBy record.field('mods:relatedItem')
    				   .match_attribute(:type 'isReferencedBy')
    				   .field('mods:titleInfo', 'mods:title')
    
    isReplacedBy record.field('mods:relatedItem')
    				   .match_attribute(:type 'isReferencedBy')
    				   .field('mods:titleInfo', 'mods:url')	
    				   
    replaces record.field('mods:relatedItem')
    				   .match_attribute(:type 'references')
    				   .field('mods:titleInfo', 'mods:title')
    				   
    replaces record.field('mods:relatedItem')
    				   .match_attribute(:type 'references')
    				   .field('mods:titleInfo', 'mods:url')
    				   	   
    rights record.field('mods:accessCondition')

    subject :class => DPLA::MAP::Concept,
            :each => record.field('mods:subject'),
            :as => :subject do
      providedLabel subject
    end
    
    #is that the right way to handle temporal?
    temporal :class => DPLA::MAP::TimeSpan,
    		 :each => record.field('mods:subject', 'mods:temporal')
    		 :as => :temporal do
      date temporal
    end

    #again guess with the ".reject"
    title record.field('mods:titleInfo')
                .reject(:type 'alternative')
                .field('mods:title')

    # Selecting DCMIType-only values will be handled in enrichment
    dctype record.field('mods:typeOfResource')
  end
end