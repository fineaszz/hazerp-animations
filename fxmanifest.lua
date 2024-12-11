fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
version '1.0.0'
shared_script {
    '@es_extended/imports.lua', 
    'config.lua',
}
server_scripts {
    'server/main.lua',
    'server/dostosuj.lua',
}
client_scripts {
    'client/main.lua',
    'client/dostosuj.lua',
}
dependencies {
    'es_extended',
}
ui_page {
    'html/index.html'
}
files {
    'html/**', 
}
escrow_ignore {
    'html/**',
    'config.lua',
}
data_file 'DLC_ITYP_REQUEST' 'stream/taymckenzienz_rpemotes.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/brummie_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/apple_1.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/kaykaymods_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/knjgh_pizzas.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/natty_props_lollipops.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/ultra_ringcase.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/pata_props.ytyp'
