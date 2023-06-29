.\lcf2xml.exe RPG_RT.ldb RPG_RT.lmt
rm EASY_RT.edb
rm EASY_RT.emt
rm *.emu
mv RPG_RT.emt EASY_RT.emt

((Get-Content -path RPG_RT.edb -Raw) `
-replace '<ldb_id>0</ldb_id>','<ldb_id>2003</ldb_id>' `
-replace '<menu_commands>1</menu_commands>','<menu_commands>1 2 3 4</menu_commands>' `
-replace '<easyrpg_use_rpg2k_battle_system>F','<easyrpg_use_rpg2k_battle_system>T' `
-replace '<easyrpg_battle_use_rpg2ke_strings>F','<easyrpg_battle_use_rpg2ke_strings>T' `
-replace '<easyrpg_use_rpg2k_battle_commands>F','<easyrpg_use_rpg2k_battle_commands>T' `
-replace '<easyrpg_max_actor_hp>-1','<easyrpg_max_actor_hp>999' `
-replace '<easyrpg_max_enemy_hp>-1','<easyrpg_max_enemy_hp>9999' `
-replace '<easyrpg_max_damage>-1','<easyrpg_max_damage>999' `
-replace '<easyrpg_max_exp>-1','<easyrpg_max_exp>999999' `
-replace '<easyrpg_max_level>-1','<easyrpg_max_level>50' `
-replace '<easyrpg_max_item_count>-1','<easyrpg_max_item_count>999' `
-replace '<easyrpg_variable_min_value>0','<easyrpg_variable_min_value>-999999' `
-replace '<easyrpg_variable_max_value>0','<easyrpg_variable_max_value>999999' `
-replace '<easyrpg_alternative_exp>0','<easyrpg_alternative_exp>1' `
) | Set-Content -Path EASY_RT.edb
rm RPG_RT.edb

if(-not(Test-path ultimate_rt_eb.dll -PathType leaf))
{
$null > ultimate_rt_eb.dll
}
if(-not(Test-path accord.dll -PathType leaf))
{
$null > accord.dll
}