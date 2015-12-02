require 'json'
require 'open-uri'

require 'active_support'
require 'active_support/core_ext/string'

module Jekyll
  class EverypoliticianPopolo < Generator
    def generate(site)
      popolo_url = File.read('DATASOURCE').chomp
      popolo = JSON.parse(open(popolo_url).read)
      memberships = popolo['memberships']
      popolo.keys.each do |collection_name|
        next unless popolo[collection_name].is_a?(Array)
        collection = Collection.new(site, collection_name)
        popolo[collection_name].each do |item|
          next unless item['id']
          path = File.join(site.source, "_#{collection_name}", "#{item['id'].parameterize}.md")
          doc = Document.new(path, collection: collection, site: site)
          doc.merge_data!(item)
          doc.merge_data!(
            'title' => item['name'],
            'layout' => collection_name,
            'memberships' => memberships_for(item, collection_name, memberships)
          )
          if collection_name == 'persons' && !item['image']
            doc.merge_data!(
              'image' => '/assets/person-210x210.jpg'
            )
          end
          collection.docs << doc
        end
        site.collections[collection_name] = collection
      end

      memberships.each do |membership|
        membership['person'] = site.collections['persons'].docs.find { |p| p.data['id'] == membership['person_id'] }
        membership['area'] = site.collections['areas'].docs.find { |a| a.data['id'] == membership['area_id'] }
        membership['legislative_period'] = site.collections['events'].docs.find { |e| e.data['id'] == membership['legislative_period_id'] }
        membership['organization'] = site.collections['organizations'].docs.find { |o| o.data['id'] == membership['organization_id'] }
        membership['party'] = site.collections['organizations'].docs.find { |o| o.data['id'] == membership['on_behalf_of_id'] }
      end
    end

    def memberships_for(item, collection_name, memberships)
      map = {
        'areas' => 'area_id',
        'persons' => 'person_id',
        'events' => 'legislative_period_id',
        'organizations' => 'on_behalf_of_id'
      }
      memberships.find_all { |m| m[map[collection_name]] == item['id'] }
    end
  end
end
