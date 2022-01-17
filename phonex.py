#!/bin/python
# -*- coding: UTF-8 -*-

#Origine : Algorithme Phonex de Frédéric BROUARD (31/3/99)
#Source : http://sqlpro.developpez.com/cours/soundex
#Version Python : Christian Pennaforte - 5 avril 2005
#Suite : Florent Carlier

import re
import unicodedata
import pandas as pd


def remove_accents(input_str):
    """
    >>> remove_accents("héhé")
    "hehe
    """
    nfkd_form = unicodedata.normalize('NFKD', input_str)
    only_ascii = nfkd_form.encode('ASCII', 'ignore')
    return only_ascii.decode("utf8")


def phonex(list_chaine):
  #0 On met la chaîne en majuscules, on vire les caractères parasites
  #trans = str.maketrans('àâäãéèêëìîïòôöõùûüñ','AAAAYYYYIIIOOOOUUUN');
  #chaine = chaine.translate(trans," -.+*/,:;_'")
  res_final = []
  for i in range(len(list_chaine)):
      
      chaine = list_chaine[i]
      
      # 0 On met la chaîne en majuscules, on vire les caractères parasites
      chaine = remove_accents(chaine)
      chaine = re.sub(r"[ \-.+*/,:;_']", "", chaine)
      chaine = chaine.upper()

      
      # 1 remplacer les y par des i
      r = chaine.replace('Y', 'I')

      # 2 supprimer les h qui ne sont pas précédées de c ou de s ou de p
      r = re.sub(r'([^PCS])H', r'\1', r)

      # 3 remplacement du ph par f
      r = r.replace(r'PH', r'F')

      # 4 remplacer les groupes de lettres suivantes :
      r = re.sub(r'G(AI?[NM])', r'K\1', r)

      # 5 remplacer les occurrences suivantes, si elles sont suivies par une lettre a, e, i, o, ou u :
      r = re.sub(r'[AE]I[NM]([AEIOU])', r'YN\1', r)

      # 6 remplacement de groupes de 3 lettres (sons 'o', 'oua', 'ein') :
      r = r.replace('EAU', 'O')
      r = r.replace('OUA', '2')
      r = r.replace('EIN', '4')
      r = r.replace('AIN', '4')
      r = r.replace('EIM', '4')
      r = r.replace('AIM', '4')

      # 7 remplacement du son É:
      r = r.replace('É', 'Y')  # CP : déjà fait en étape 0
      r = r.replace('È', 'Y')  # CP : déjà fait en étape 0
      r = r.replace('Ê', 'Y')  # CP : déjà fait en étape 0
      r = r.replace('AI', 'Y')
      r = r.replace('EI', 'Y')
      r = r.replace('ER', 'YR')
      r = r.replace('ESS', 'YS')
      r = r.replace('ET', 'YT')  # CP : différence entre la version Delphi et l'algo
      r = r.replace('EZ', 'YZ')

      # 8 remplacer les groupes de 2 lettres suivantes (son â..anâ.. et â..inâ..), sauf sâ..il sont suivi par une
      # lettre a, e, i o, u ou un son 1 Ã  4 :
      r = re.sub(r'AN([^AEIOU1234])', r'1\1', r)
      r = re.sub(r'ON([^AEIOU1234])', r'1\1', r)
      r = re.sub(r'AM([^AEIOU1234])', r'1\1', r)
      r = re.sub(r'EN([^AEIOU1234])', r'1\1', r)
      r = re.sub(r'EM([^AEIOU1234])', r'1\1', r)
      r = re.sub(r'IN([^AEIOU1234])', r'4\1', r)

      # 9 remplacer les s par des z sâ..ils sont suivi et précédés des lettres a, e, i, o,u ou dâ..un son 1 Ã  4
      r = re.sub(r'([AEIOUY1234])S([AEIOUY1234])', r'\1Z\2', r)
      # CP : ajout du Y Ã  la liste

      # 10 remplacer les groupes de 2 lettres suivants :
      r = r.replace('OE', 'E')
      r = r.replace('EU', 'E')
      r = r.replace('AU', 'O')
      r = r.replace('OI', '2')
      r = r.replace('OY', '2')
      r = r.replace('OU', '3')

      # 11 remplacer les groupes de lettres suivants
      r = r.replace('CH', '5')
      r = r.replace('SCH', '5')
      r = r.replace('SH', '5')
      r = r.replace('SS', 'S')
      r = r.replace('SC', 'S')  # CP : problème pour PASCAL, mais pas pour PISCINE ?

      # 12 remplacer le c par un s s'il est suivi d'un e ou d'un i
      # CP : à mon avis, il faut inverser 11 et 12 et ne pas faire la dernière ligne du 11
      r = re.sub(r'C([EI])', r'S\1', r)

      # 13 remplacer les lettres ou groupe de lettres suivants :
      r = r.replace('C', 'K')
      r = r.replace('Q', 'K')
      r = r.replace('QU', 'K')
      r = r.replace('GU', 'K')
      r = r.replace('GA', 'KA')
      r = r.replace('GO', 'KO')
      r = r.replace('GY', 'KY')

      # 14 remplacer les lettres suivante :
      r = r.replace('A', 'O')
      r = r.replace('D', 'T')
      r = r.replace('P', 'T')
      r = r.replace('J', 'G')
      r = r.replace('B', 'F')
      r = r.replace('V', 'F')
      r = r.replace('M', 'N')

      # 15 Supprimer les lettres dupliquées
      oldc = '#'
      newr = ''
      for c in r:
          if oldc != c: newr = newr + c
          oldc = c
      r = newr

      # 16 Supprimer les terminaisons suivantes : t, x
      r = re.sub(r'(.*)[TX]$', r'\1', r)

      
      res_final.append(r)
    
  return res_final


def phonex_num(list_chaine):
  #0 On met la chaîne en majuscules, on vire les caractères parasites
  #trans = str.maketrans('àâäãéèêëìîïòôöõùûüñ','AAAAYYYYIIIOOOOUUUN');
  #chaine = chaine.translate(trans," -.+*/,:;_'")
  res_final = []
  for s in range(len(list_chaine)):
      
      chaine = list_chaine[s]
      
      # 0 On met la chaîne en majuscules, on vire les caractères parasites
      chaine = remove_accents(chaine)
      chaine = re.sub(r"[ \-.+*/,:;_']", "", chaine)
      chaine = chaine.upper()

      
      # 1 remplacer les y par des i
      r = chaine.replace('Y', 'I')

      # 2 supprimer les h qui ne sont pas précédées de c ou de s ou de p
      r = re.sub(r'([^PCS])H', r'\1', r)

      # 3 remplacement du ph par f
      r = r.replace(r'PH', r'F')

      # 4 remplacer les groupes de lettres suivantes :
      r = re.sub(r'G(AI?[NM])', r'K\1', r)

      # 5 remplacer les occurrences suivantes, si elles sont suivies par une lettre a, e, i, o, ou u :
      r = re.sub(r'[AE]I[NM]([AEIOU])', r'YN\1', r)

      # 6 remplacement de groupes de 3 lettres (sons 'o', 'oua', 'ein') :
      r = r.replace('EAU', 'O')
      r = r.replace('OUA', '2')
      r = r.replace('EIN', '4')
      r = r.replace('AIN', '4')
      r = r.replace('EIM', '4')
      r = r.replace('AIM', '4')

      # 7 remplacement du son É:
      r = r.replace('É', 'Y')  # CP : déjà fait en étape 0
      r = r.replace('È', 'Y')  # CP : déjà fait en étape 0
      r = r.replace('Ê', 'Y')  # CP : déjà fait en étape 0
      r = r.replace('AI', 'Y')
      r = r.replace('EI', 'Y')
      r = r.replace('ER', 'YR')
      r = r.replace('ESS', 'YS')
      r = r.replace('ET', 'YT')  # CP : différence entre la version Delphi et l'algo
      r = r.replace('EZ', 'YZ')

      # 8 remplacer les groupes de 2 lettres suivantes (son â..anâ.. et â..inâ..), sauf sâ..il sont suivi par une
      # lettre a, e, i o, u ou un son 1 Ã  4 :
      r = re.sub(r'AN([^AEIOU1234])', r'1\1', r)
      r = re.sub(r'ON([^AEIOU1234])', r'1\1', r)
      r = re.sub(r'AM([^AEIOU1234])', r'1\1', r)
      r = re.sub(r'EN([^AEIOU1234])', r'1\1', r)
      r = re.sub(r'EM([^AEIOU1234])', r'1\1', r)
      r = re.sub(r'IN([^AEIOU1234])', r'4\1', r)

      # 9 remplacer les s par des z sâ..ils sont suivi et précédés des lettres a, e, i, o,u ou dâ..un son 1 Ã  4
      r = re.sub(r'([AEIOUY1234])S([AEIOUY1234])', r'\1Z\2', r)
      # CP : ajout du Y Ã  la liste

      # 10 remplacer les groupes de 2 lettres suivants :
      r = r.replace('OE', 'E')
      r = r.replace('EU', 'E')
      r = r.replace('AU', 'O')
      r = r.replace('OI', '2')
      r = r.replace('OY', '2')
      r = r.replace('OU', '3')

      # 11 remplacer les groupes de lettres suivants
      r = r.replace('CH', '5')
      r = r.replace('SCH', '5')
      r = r.replace('SH', '5')
      r = r.replace('SS', 'S')
      r = r.replace('SC', 'S')  # CP : problème pour PASCAL, mais pas pour PISCINE ?

      # 12 remplacer le c par un s s'il est suivi d'un e ou d'un i
      # CP : à mon avis, il faut inverser 11 et 12 et ne pas faire la dernière ligne du 11
      r = re.sub(r'C([EI])', r'S\1', r)

      # 13 remplacer les lettres ou groupe de lettres suivants :
      r = r.replace('C', 'K')
      r = r.replace('Q', 'K')
      r = r.replace('QU', 'K')
      r = r.replace('GU', 'K')
      r = r.replace('GA', 'KA')
      r = r.replace('GO', 'KO')
      r = r.replace('GY', 'KY')

      # 14 remplacer les lettres suivante :
      r = r.replace('A', 'O')
      r = r.replace('D', 'T')
      r = r.replace('P', 'T')
      r = r.replace('J', 'G')
      r = r.replace('B', 'F')
      r = r.replace('V', 'F')
      r = r.replace('M', 'N')

      # 15 Supprimer les lettres dupliquées
      oldc = '#'
      newr = ''
      for c in r:
          if oldc != c: newr = newr + c
          oldc = c
      r = newr

      # 16 Supprimer les terminaisons suivantes : t, x
      r = re.sub(r'(.*)[TX]$', r'\1', r)

      # 17 Affecter à chaque lettre le code numérique correspondant en partant de la dernière lettre
      num = ['1', '2', '3', '4', '5', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'N', 'O', 'R', 'S', 'T', 'U', 'W', 'X', 'Y', 'Z']
      l = []
      for c in r:
          l.append(num.index(c))

      # 18 Convertissez les codes numériques ainsi obtenu en un nombre de base 22 exprimé en virgule flottante.
      res = 0.
      i = 1
      for n in l:
          res = n * 22 ** -i + res
          i = i + 1
      res_final.append(res)
    
  return res_final


############### INSEE data ##################
file = 'D:/Maryam/SBE_PIGAS/Final/INSEE_Mortality/dcd_2016_2021_extractforphonex.sas7bdat'

df = pd.read_sas(file, format = 'sas7bdat', encoding="latin-1")

df = df.astype({'num_insee_all':int})
df = df.fillna('')

df['nom_phonex'] = phonex(df['nom'])
df['nom_phonex_num'] = phonex_num(df['nom'])
df['nom1_phonex'] = phonex(df['nom1'])
df['nom1_phonex_num'] = phonex_num(df['nom1'])
df['nom2_phonex'] = phonex(df['nom2'])
df['nom2_phonex_num'] = phonex_num(df['nom2'])
df['nom3_phonex'] = phonex(df['nom3'])
df['nom3_phonex_num'] = phonex_num(df['nom3'])
df['prenom1_phonex'] = phonex(df['prenom1'])
df['prenom1_phonex_num'] = phonex_num(df['prenom1'])
df['prenom2_phonex'] = phonex(df['prenom2'])
df['prenom2_phonex_num'] = phonex_num(df['prenom2'])
df['prenom3_phonex'] = phonex(df['prenom3'])
df['prenom3_phonex_num'] = phonex_num(df['prenom3'])
df['nom_comp_phonex'] = phonex(df['nom_comp'])
df['nom_comp_phonex_num'] = phonex_num(df['nom_comp'])
df['prenom_comp_phonex'] = phonex(df['prenom_comp'])
df['prenom_comp_phonex_num'] = phonex_num(df['prenom_comp'])

df_converted = df[['num_insee_all','nom_phonex','nom_phonex_num','nom1_phonex','nom1_phonex_num','nom2_phonex','nom2_phonex_num','nom3_phonex','nom3_phonex_num','prenom1_phonex','prenom1_phonex_num','prenom2_phonex','prenom2_phonex_num','prenom3_phonex','prenom3_phonex_num','nom_comp_phonex','nom_comp_phonex_num','prenom_comp_phonex','prenom_comp_phonex_num']]
df_converted.to_csv("D:/Maryam/SBE_PIGAS/Final/INSEE_Mortality/dcd_2016_2021_phonex.csv",index=False)


############### IGR data ##################
file = 'D:/Maryam/SBE_PIGAS/Final/Data_IGR/Extraction_25_05_2020/base_igr2016_extractforphonex.sas7bdat'

df = pd.read_sas(file, format = 'sas7bdat', encoding="latin-1")

df = df.astype({'noigr':int})
df = df.fillna('')

df['igr_nom1_phonex'] = phonex(df['igr_nom1'])
df['igr_nom2_phonex'] = phonex(df['igr_nom2'])
df['igr_nom3_phonex'] = phonex(df['igr_nom3'])
df['igr_nom4_phonex'] = phonex(df['igr_nom4'])
df['igr_nom5_phonex'] = phonex(df['igr_nom5'])
df['igr_nom_comp_phonex'] = phonex(df['igr_nom_comp'])
df['igr_prenom_comp_phonex'] = phonex(df['igr_prenom_comp'])
df['igr_prenom1_phonex'] = phonex(df['igr_prenom1'])
df['igr_prenom2_phonex'] = phonex(df['igr_prenom2'])
df['igr_prenom3_phonex'] = phonex(df['igr_prenom3'])
df['igr_prenom4_phonex'] = phonex(df['igr_prenom4'])
df['igr_nom_jf1_phonex'] = phonex(df['igr_nom_jf1'])
df['igr_nom_jf2_phonex'] = phonex(df['igr_nom_jf2'])
df['igr_nom_jf3_phonex'] = phonex(df['igr_nom_jf3'])
df['igr_nom_jf4_phonex'] = phonex(df['igr_nom_jf4'])
df['igr_nom_jf5_phonex'] = phonex(df['igr_nom_jf5'])
df['igr_nom_m1_phonex'] = phonex(df['igr_nom_m1'])
df['igr_nom_m2_phonex'] = phonex(df['igr_nom_m2'])
df['igr_nom_m3_phonex'] = phonex(df['igr_nom_m3'])
df['igr_nom_m4_phonex'] = phonex(df['igr_nom_m4'])
df['igr_nom_m5_phonex'] = phonex(df['igr_nom_m5'])

df['igr_nom1_phonex_num'] = phonex_num(df['igr_nom1'])
df['igr_nom2_phonex_num'] = phonex_num(df['igr_nom2'])
df['igr_nom3_phonex_num'] = phonex_num(df['igr_nom3'])
df['igr_nom4_phonex_num'] = phonex_num(df['igr_nom4'])
df['igr_nom5_phonex_num'] = phonex_num(df['igr_nom5'])
df['igr_nom_comp_phonex_num'] = phonex_num(df['igr_nom_comp'])
df['igr_prenom_comp_phonex_num'] = phonex_num(df['igr_prenom_comp'])
df['igr_prenom1_phonex_num'] = phonex_num(df['igr_prenom1'])
df['igr_prenom2_phonex_num'] = phonex_num(df['igr_prenom2'])
df['igr_prenom3_phonex_num'] = phonex_num(df['igr_prenom3'])
df['igr_prenom4_phonex_num'] = phonex_num(df['igr_prenom4'])
df['igr_nom_jf1_phonex_num'] = phonex_num(df['igr_nom_jf1'])
df['igr_nom_jf2_phonex_num'] = phonex_num(df['igr_nom_jf2'])
df['igr_nom_jf3_phonex_num'] = phonex_num(df['igr_nom_jf3'])
df['igr_nom_jf4_phonex_num'] = phonex_num(df['igr_nom_jf4'])
df['igr_nom_jf5_phonex_num'] = phonex_num(df['igr_nom_jf5'])
df['igr_nom_m1_phonex_num'] = phonex_num(df['igr_nom_m1'])
df['igr_nom_m2_phonex_num'] = phonex_num(df['igr_nom_m2'])
df['igr_nom_m3_phonex_num'] = phonex_num(df['igr_nom_m3'])
df['igr_nom_m4_phonex_num'] = phonex_num(df['igr_nom_m4'])
df['igr_nom_m5_phonex_num'] = phonex_num(df['igr_nom_m5'])


df_converted = df[['noigr','igr_nom1_phonex', 'igr_nom2_phonex','igr_nom3_phonex','igr_nom4_phonex','igr_nom5_phonex','igr_prenom1_phonex','igr_prenom2_phonex','igr_prenom3_phonex','igr_prenom4_phonex','igr_nom_jf1_phonex', 'igr_nom_jf2_phonex','igr_nom_jf3_phonex','igr_nom_jf4_phonex','igr_nom_jf5_phonex','igr_nom_m1_phonex', 'igr_nom_m2_phonex','igr_nom_m3_phonex','igr_nom_m4_phonex','igr_nom_m5_phonex','igr_nom1_phonex_num', 'igr_nom2_phonex_num','igr_nom3_phonex_num','igr_nom4_phonex_num','igr_nom5_phonex_num','igr_prenom1_phonex_num','igr_prenom2_phonex_num','igr_prenom3_phonex_num','igr_prenom4_phonex_num','igr_nom_jf1_phonex_num', 'igr_nom_jf2_phonex_num','igr_nom_jf3_phonex_num','igr_nom_jf4_phonex_num','igr_nom_jf5_phonex_num','igr_nom_m1_phonex_num', 'igr_nom_m2_phonex_num','igr_nom_m3_phonex_num','igr_nom_m4_phonex_num','igr_nom_m5_phonex_num','igr_nom_comp_phonex','igr_prenom_comp_phonex','igr_nom_comp_phonex_num','igr_prenom_comp_phonex_num']]

df_converted.to_csv("D:/Maryam/SBE_PIGAS/Final/Data_IGR/Extraction_25_05_2020/base_igr2016_phonex.csv",index=False)



