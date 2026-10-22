# Ours, not the gem's: registration is the only thing that resolves the name
# config/search.yml gives. SQLite uses the gem's own adapter.
ActiveSearch.register_adapter :mysql_sharded, "ActiveSearch::StoreAdapters::MysqlSharded"

ActiveSearch.define_index(:searchable, polymorphic: true, route_by: :account_id,
                          document_class: "Search::Record") do
  text :title
  text :content
  string :account_id
  string :board_id
  string :card_id
  string :searchable_type
  string :searchable_id
  datetime :created_at
end
