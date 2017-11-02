class Materiel < ApplicationRecord
  def description_courte
    desc = HTMLEntities.new.decode(self.description.gsub(/<.*?>/, ''))
    coupure = desc.index(' ', 120)
    if coupure.nil?
      desc
    else
      desc[0, coupure] + ' ...'
    end
  end

  def nom_poids_et_reforme
    nom + ' : ' + poids.to_s + ' g ' + (self.reforme ? '(réformé)' : '')
  end

  validates :nom, presence: true
  validates :description, presence: true
  validates :photo, presence: true
  validates :poids, presence: true, numericality: { only_integer: true}

  has_and_belongs_to_many :traces
end
