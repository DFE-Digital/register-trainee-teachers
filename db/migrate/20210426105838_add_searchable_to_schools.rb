class AddSearchableToSchools < ActiveRecord::Migration[6.1]
  def up
    add_column :schools, :searchable, :tsvector
    add_index :schools, :searchable, using: :gin

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON schools FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(searchable, 'pg_catalog.simple', urn, name, postcode, town);
    SQL
  end

  def down
    execute "DROP TRIGGER tsvectorupdate ON schools"

    remove_index :schools, :searchable
    remove_column :schools, :searchable
  end
end


__END__

irb(main):013:0> SchoolSearch.call(query: "a").analyze
                                                                          QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------
--------------
 Sort  (cost=4288.64..4301.39 rows=5098 width=211) (actual time=50.240..50.776 rows=7667 loops=1)
   Sort Key: (ts_rank(schools_1.searchable, '''a'':*'::tsquery, 0)) DESC, schools.id
   Sort Method: quicksort  Memory: 3004kB
   ->  Hash Join  (cost=1910.39..3974.72 rows=5098 width=211) (actual time=12.923..35.951 rows=7667 loops=1)
         Hash Cond: (schools.id = schools_1.id)
         ->  Seq Scan on schools  (cost=0.00..1980.81 rows=26954 width=207) (actual time=0.005..12.401 rows=27283 loops=1)
               Filter: (close_date IS NULL)
               Rows Removed by Filter: 21746
         ->  Hash  (cost=1794.59..1794.59 rows=9264 width=129) (actual time=12.902..12.903 rows=11608 loops=1)
               Buckets: 16384  Batches: 1  Memory Usage: 2140kB
               ->  Bitmap Heap Scan on schools schools_1  (cost=187.79..1794.59 rows=9264 width=129) (actual time=3.920..9.041 rows=11608 loops=1
)
                     Recheck Cond: (searchable @@ '''a'':*'::tsquery)
                     Heap Blocks: exact=1464
                     ->  Bitmap Index Scan on index_schools_on_searchable  (cost=0.00..185.48 rows=9264 width=0) (actual time=3.737..3.737 rows=1
1608 loops=1)
                           Index Cond: (searchable @@ '''a'':*'::tsquery)
 Planning Time: 0.431 ms
 Execution Time: 52.593 ms
(17 rows)

irb(main):013:0> SchoolSearch.call(query: "alper").analyze
=>
EXPLAIN ANALYZE for: SELECT "schools".* FROM "schools" INNER JOIN (SELECT "schools"."id" AS pg_search_id, (ts_rank(("schools"."searchable"), (to_
tsquery('simple', ''' ' || 'alper' || ' ''' || ':*')), 0)) AS rank FROM "schools" WHERE (("schools"."searchable") @@ (to_tsquery('simple', ''' '
|| 'alper' || ' ''' || ':*')))) AS pg_search_f79e2ecc220dc52eaea688 ON "schools"."id" = pg_search_f79e2ecc220dc52eaea688.pg_search_id WHERE "scho
ols"."close_date" IS NULL ORDER BY pg_search_f79e2ecc220dc52eaea688.rank DESC, "schools"."id" ASC
                                                                    QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------
--
 Sort  (cost=327.98..328.01 rows=10 width=211) (actual time=0.453..0.454 rows=1 loops=1)
   Sort Key: (ts_rank(schools_1.searchable, '''alper'':*'::tsquery, 0)) DESC, schools.id
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=104.44..327.82 rows=10 width=211) (actual time=0.447..0.448 rows=1 loops=1)
         ->  Bitmap Heap Scan on schools schools_1  (cost=104.15..173.95 rows=19 width=129) (actual time=0.426..0.429 rows=2 loops=1)
               Recheck Cond: (searchable @@ '''alper'':*'::tsquery)
               Heap Blocks: exact=2
               ->  Bitmap Index Scan on index_schools_on_searchable  (cost=0.00..104.14 rows=19 width=0) (actual time=0.423..0.423 rows=2 loops=1
)
                     Index Cond: (searchable @@ '''alper'':*'::tsquery)
         ->  Index Scan using schools_pkey on schools  (cost=0.29..8.10 rows=1 width=207) (actual time=0.006..0.006 rows=0 loops=2)
               Index Cond: (id = schools_1.id)
               Filter: (close_date IS NULL)
               Rows Removed by Filter: 0
 Planning Time: 0.475 ms
 Execution Time: 0.497 ms
(15 rows)

irb(main):014:0>
