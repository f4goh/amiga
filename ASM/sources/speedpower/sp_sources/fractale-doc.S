
	************************************************************
	************************************************************
	**							  **
	**   DOCUMENTATION:    FRACTALES (mandelbrot et julia)    **
	**   AUTEUR:	       CODY FROM DEFCON4		  **
	**   MIS A JOUR POUR:  SPECTRE FROM PROFECY		  **
	**   DATE:             10-09-91				  **
	**							  **
	************************************************************
	************************************************************


INTRODUCTION:
*************

	- les fractales sont a l'heure actuelle present dans le nombreuses 
demos, ces fantastiques objets mathematiques qui peuvent paraitre extremement
complexes a gerer sont en fait tres simples a representer et ne demandent que
peu de connaissances mathematiques.

	- je vais donc tenter dans un premier temps d'introduire le principe
mathematique des fractales puis de fournir quelques explications au sujet des
sources ( MANDELBROT.GENERATOR ET JULIA.GENERATOR ) present sur cette disquette


PRELIMINAIRES MATHEMATIQUE :
****************************

	- les fractales sont une nouvelle branche des mathematiques, apparut il
y quelques annees MANDELBROT (docteur en mathematiques,directeur des recherches
chez IBM) en est l'un des fondateurs les plus reconnut.

	- l'observation de certains phenomenes ou objets naturels (exemple:
depressions atmospheriques, fougeres, feuilles de vegetaux, nuages...) a permit
de se rendre compte qu'ils semblaientt etre constitue d'une figure geometrique d
de base (triangle,pentagone,carre...)

	- Mandelbrot entrepris donc de representer une figure simple 
(la premiere fut un triangle), puis il redessinat ce triangle dans le premier
triangle suivant une echelle et un angle particuliere, il repeta cette
operation n fois en faisant varier l'angle et l'echelle suivant une fonction 
euclidienne classique. l'objet obtenue etait proche de la scructure nerveuse
d'une feuille !

	- en fait toutes les fractales sont basees sur ce systeme:
  * representer une figure geometrique.
  * repeter cette figure n fois suivant un angle et une echelle generer par une
fonction euclidienne.

	- le nombre n est appelee incide de recursivite ou nombre d'iteration

	- a partir de ces principes Mandelbrot decouvrit un ensemble fractale
particulier: l'ensemble de mandelbrot
cette ensemble naquit de la similitude entre le principe des fractales et les
suites recursives ( le monbre n est present dans ces 2 outils ).


L'ENSEMBLE DE MANDELBROT:
*************************

	- lié aux nombres complexes l'equation de cette ensemble est:

		Z0=0
		Zn+1= Zn²+c	( c etant un nombre complexe )

	- un micro-ordinateur etant incapable de gerer les nombres complexes
on identifie donc partie reelle et partie imaginaire de cette suite.	  

		on pose:	Zn=A+iB		et 	c=A+iB
		on obtient:	Zn+1=(A+iB)²+(A+iB)
		soit:		Zn+1=A²+2iAB-B²+A+iB

			      ***************************
			      *	Zn+1=(A²+A-B²)+i(2AB+B)	*
		avec:	      *	Z0=0			*
			      ***************************

	- on represente donc la partie reelle sur l'abscisse x et la partie
imaginaire sur l'axe des l'ordonnee y.
	- pour le traitement des couleurs on procede de la facon suivante:
on choisit une constante k que l'on compare a Z0 si Z0<k on calcule Z1 si
Z1<k on calcule Z2 etc... jusque Zn>k on affiche alorsle point calculee suivant
la couleur n.

	-afin de mieux comprendre le principe je conseille vivement l'etude 
du programme GFA present sur la disquette.


L'ENSEMBLE DE JULIA:
********************

	-l'ensemble de JULIA est un derivee de l'ensemble de MANDELBROT, il
utilise une propriete des nombres complexes en fixant une constante pour x et
y on obtient une fractale qui subit une rotation.

EXTENSION A D'AUTRE ENSEMBLE:
*****************************

	-tout les delires sont possibles, la modifications d'un seul
parametre de la suite peut aboutir a des resultats surprenants:

exemple:	Zn+1=Zn²+c²	etc...

