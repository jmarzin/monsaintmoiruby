class Madate
  def initialize(jour, mois, annee)
    @jour = jour
    @mois = mois
    @annee = annee
  end

  def ecart_texte(valeur, texte)
    return '' if valeur <= 0
    return valeur.to_s + ' ' + texte if valeur == 1 || texte.end_with?('s')
    valeur.to_s + ' ' + texte + 's'
  end

  def ecart(jour, mois, annee)
    if jour < @jour
      case mois
      when 2, 4, 6, 8, 10, 12
        jour += 31
      when 3
        jour += 28
      else
        jour += 30
      end
      mois -= 1
    end
    if mois < @mois
      mois += 12
      annee -= 1
      jour+=1 if mois % 2 == 0
    end
    return 'Je suis déjà parti !' if annee < @annee
    res = ecart_texte(annee - @annee, 'année') + ' ' +
      ecart_texte(mois - @mois, 'mois') + ' ' +
      ecart_texte(jour - @jour, 'jour')
    res.gsub(/^ +/, "").gsub(/ +$/, "").gsub(/  /, " ")
  end
end
