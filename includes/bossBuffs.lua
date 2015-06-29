
function bossBuffs (arg)
	
  if arg==true then
	 
    if player.Class1 == CLASS_SCOUT then
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490464)..'")') yrest (1100)	-- target area      
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490460)..'")') yrest (1100)	-- concentration
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490494)..'")') yrest (1100)	-- arrow of essence
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490434)..'")') 							-- Blood Arrow
				 
    elseif player.Class1 == CLASS_PRIEST then
      changeProfileSkill ('PRIEST_HEALING_SALVE',	'AutoUse', true)
      changeProfileSkill ('PRIEST_WAVE_ARMOR', 		'AutoUse', true)
				 
    elseif player.Class1 == CLASS_ROGUE then
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490506)..'")') yrest (1100)	-- Assasins rage
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490507)..'")') yrest (1100)	-- premeditation
      SlashCommand ('/script CastSpellByName ("'..GetIdName (491528)..'")') yrest (1100)	-- energy thief
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490333)..'")') yrest (1100)	-- ferverant attack
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490350)..'")') yrest (1100)	-- informer
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490355)..'")') 							-- evasion
				 
    elseif player.Class1 == CLASS_MAGE then
      changeProfileOption ('COMBAT_DISTANCE', 			200)
      changeProfileSkill ('MAGE_PURGATORY_FIRE',		'AutoUse', false)
			changeProfileSkill ('MAGE_THUNDERSTORM',			'AutoUse', false)
      changeProfileSkill ('MAGE_FLAME', 						'AutoUse', true)      
      changeProfileSkill ('MAGE_FIREBALL' ,					'AutoUse', true)
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490218)..'")') yrest (1100)	-- energiezufuhr
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490251)..'")') yrest (1100)	-- energiebrunnen
      SlashCommand ('/script CastSpellByName ("'..GetIdName (497976)..'")') yrest (1100)	-- intensivierung
      SlashCommand ('/script CastSpellByName ("'..GetIdName (490238)..'")') yrest (1100)	-- elementarkatalyse
			
		end
			
    if player.Class1 == CLASS_WARDEN or player.Class2 == CLASS_WARDEN then
      SlashCommand ('/script CastSpellByName ("'..GetIdName (493402)..'")') yrest (1100)	-- elven amulet
      SlashCommand ('/script CastSpellByName ("'..GetIdName (493406)..'")') 							-- savage power
    end
			
  else
	 
    if player.Class1 == CLASS_MAGE then
			changeProfileOption ('COMBAT_DISTANCE', 				50)
			changeProfileSkill ('MAGE_THUNDERSTORM',				'AutoUse', true)
			changeProfileSkill ('MAGE_THUNDERSTORM',				'priority', 100)
			changeProfileSkill ('MAGE_PURGATORY_FIRE',			'AutoUse', true)
			changeProfileSkill ('MAGE_PURGATORY_FIRE',			'priority', 90)
			changeProfileSkill ('MAGE_FLAME',								'AutoUse', false)
			changeProfileSkill ('MAGE_FIREBALL',						'AutoUse', false)
			
		elseif player.Class1 == CLASS_PRIEST then
			changeProfileSkill ('PRIEST_HEALING_SALVE',			'AutoUse', false)
			changeProfileSkill ('PRIEST_WAVE_ARMOR',				'AutoUse', false)
		end
  end
end
