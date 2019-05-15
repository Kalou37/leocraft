extends Node2D

var lstSprite = []

var pageEnCours:int
const maxPage:int = 3
var positionCurseur:int

var img1
var img2
var img3


func _ready():
	img1 = preload("res://assets/UI/explain1.png")
	img2 = preload("res://assets/UI/explain2.png")
	img3 = preload("res://assets/UI/explain3.png")
	
	pageEnCours = 1
	positionCurseur = 1
	lstSprite = get_children()
	for i in range(1, lstSprite.size() ):
		lstSprite[i].visible = false
	$Retour1.visible = true
	$Suivant.visible = true
	$JeuHover.visible = true
	$Explain.visible = true

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		#on_valid_menu()
		if (positionCurseur == 0):
			if(pageEnCours == 1):
				get_node("/root/Node2D").virer_instructions()
				queue_free()
			elif(pageEnCours == 2):
				pageEnCours -= 1
				$Explain.texture = img1
				change_selecteur()
			elif(pageEnCours == 3):
				pageEnCours -= 1
				$Explain.texture = img2
				change_selecteur()
				
		if (positionCurseur == 1):
			get_node("/root/Node2D").lancer_jeu()
			queue_free()
				
		if (positionCurseur == 2):
			if(pageEnCours == 1):
				pageEnCours += 1
				$Explain.texture = img2
				change_selecteur()
			elif(pageEnCours == 2):
				pageEnCours += 1
				$Explain.texture = img3
				change_selecteur()
			elif(pageEnCours == 3):
				get_node("/root/Node2D").virer_instructions()
				queue_free()
	if Input.is_action_just_pressed("ui_right"):
		if positionCurseur < 2:
			positionCurseur += 1
	if Input.is_action_just_pressed("ui_left"):
		if positionCurseur > 0:
			positionCurseur -= 1
	change_selecteur()

func change_selecteur():
	for i in range(1, lstSprite.size() ):
		lstSprite[i].visible = false
	match pageEnCours:
		1:
			if(positionCurseur == 0):
				$Retour1Hover.visible = true
				$Jeu.visible = true
				$Suivant.visible = true
				$Explain.visible = true
			elif(positionCurseur == 1):
				$Retour1.visible = true
				$JeuHover.visible = true
				$Suivant.visible = true
				$Explain.visible = true
			elif(positionCurseur == 2):
				$Retour1.visible = true
				$Jeu.visible = true
				$SuivantHover.visible = true
				$Explain.visible = true
		2:
			if(positionCurseur == 0):
				$PrecedentHover.visible = true
				$Jeu.visible = true
				$Suivant.visible = true
				$Explain.visible = true
			elif(positionCurseur == 1):
				$Precedent.visible = true
				$JeuHover.visible = true
				$Suivant.visible = true
				$Explain.visible = true
			elif(positionCurseur == 2):
				$Precedent.visible = true
				$Jeu.visible = true
				$SuivantHover.visible = true
				$Explain.visible = true
		3:
			if(positionCurseur == 0):
				$PrecedentHover.visible = true
				$Jeu.visible = true
				$Retour2.visible = true
				$Explain.visible = true
			elif(positionCurseur == 1):
				$Precedent.visible = true
				$JeuHover.visible = true
				$Retour2.visible = true
				$Explain.visible = true
			elif(positionCurseur == 2):
				$Precedent.visible = true
				$Jeu.visible = true
				$Retour2Hover.visible = true
				$Explain.visible = true