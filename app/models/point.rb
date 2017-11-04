##
# classe de gestion des points du profil de la randonnée ou du trek
class Point < ApplicationRecord
  belongs_to :trace
end