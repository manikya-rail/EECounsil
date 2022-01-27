class CreateZoomIntegrations < ActiveRecord::Migration[5.2]
  def change
    create_table :zoom_integrations do |t|
      t.string :config_name
      t.text :value

      t.timestamps
    end
    zoom_hsh = {ZOOM_OAUTH_ACCESS_TOKEN: 'eyJhbGciOiJIUzUxMiIsInYiOiIyLjAiLCJraWQiOiIxMTI0ZjYxOC02NDhmLTQ1MzUtYjRiMS1mZmEwZTkxMmVkYWIifQ.eyJ2ZXIiOiI2IiwiY2xpZW50SWQiOiJkbkY4VEtDTVNQU25TWVJaQXRjVW53IiwiY29kZSI6Im80bkhjN0NKNDJfWm9iOENNcWZSNENZbFlMVlY5clhHUSIsImlzcyI6InVybjp6b29tOmNvbm5lY3Q6Y2xpZW50aWQ6ZG5GOFRLQ01TUFNuU1lSWkF0Y1VudyIsImF1dGhlbnRpY2F0aW9uSWQiOiJhNGIxYzkyZjgwYWU5NjRlMzA5ZGQ0NzlkZWJmNTI5NiIsInVzZXJJZCI6IlpvYjhDTXFmUjRDWWxZTFZWOXJYR1EiLCJncm91cE51bWJlciI6MCwiYXVkIjoiaHR0cHM6Ly9vYXV0aC56b29tLnVzIiwiYWNjb3VudElkIjoiZ0NrWHFQV0ZUekNVMEdDUTRNakJwZyIsIm5iZiI6MTU4NzM4NzY2NywiZXhwIjoxNTg3MzkxMjY3LCJ0b2tlblR5cGUiOiJhY2Nlc3NfdG9rZW4iLCJpYXQiOjE1ODczODc2NjcsImp0aSI6ImRjZGE0Y2FkLTA3MzItNGM5OS1hZmUzLTJiMDBmNDdlYjE0MiIsInRvbGVyYW5jZUlkIjoyfQ.rEVNx9rHPsSub6nVgWF9_K2RZrcfTdUQ_PFVidShahFNxzkXrkveQNgjanibRzbfqP02e-0fuMdcYVOxNEus2w',
                ZOOM_OAUTH_REFRESH_TOKEN: 'eyJhbGciOiJIUzUxMiIsInYiOiIyLjAiLCJraWQiOiJjNTFjYTQ4Yy1kZmNmLTQwMTQtODQ3Ni0wOTI1MjBkYjBhM2YifQ.eyJ2ZXIiOiI2IiwiY2xpZW50SWQiOiJkbkY4VEtDTVNQU25TWVJaQXRjVW53IiwiY29kZSI6Im80bkhjN0NKNDJfWm9iOENNcWZSNENZbFlMVlY5clhHUSIsImlzcyI6InVybjp6b29tOmNvbm5lY3Q6Y2xpZW50aWQ6ZG5GOFRLQ01TUFNuU1lSWkF0Y1VudyIsImF1dGhlbnRpY2F0aW9uSWQiOiJhNGIxYzkyZjgwYWU5NjRlMzA5ZGQ0NzlkZWJmNTI5NiIsInVzZXJJZCI6IlpvYjhDTXFmUjRDWWxZTFZWOXJYR1EiLCJncm91cE51bWJlciI6MCwiYXVkIjoiaHR0cHM6Ly9vYXV0aC56b29tLnVzIiwiYWNjb3VudElkIjoiZ0NrWHFQV0ZUekNVMEdDUTRNakJwZyIsIm5iZiI6MTU4NzM4NzY2NywiZXhwIjoyMDYwNDI3NjY3LCJ0b2tlblR5cGUiOiJyZWZyZXNoX3Rva2VuIiwiaWF0IjoxNTg3Mzg3NjY3LCJqdGkiOiI2MGFhMjgzOS04MTE4LTQ1YjQtOGVkMS00NWNjMjE2Njk2MjAiLCJ0b2xlcmFuY2VJZCI6Mn0.2Q3lAVT3ckPXpUPi6IF0t8zfh07xYUgghVZGLrJk57iCxa5sTjXPU4_03HaH0APjtXw0Rdio3nyfamWoHINcLQ'
              }
    zoom_hsh.each do |config_name, value|
      ZoomIntegration.create!(config_name: config_name, value: value)
    end
  end
end
