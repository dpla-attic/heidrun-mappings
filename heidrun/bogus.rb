#bogus.rb
Krikri::Mapper.define(:bogus_dc, :parser => Krikri::OaiDcParser) do
  provider :class => DPLA::MAP::Agent do
    uri 'http://dp.la/api/contributor/bogus'
    label 'The Bogus Contributor'
  end
end