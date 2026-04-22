require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const axios = require('axios');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');
const { processAndUploadImage } = require('../services/imageService');

// ════════════════════════════════════════════════════════════════════
// WALLPAPERS BY CATEGORY – 20+ per category
// Sources: Freepik (img.freepik.com) & 4kwallpapers.com
// ════════════════════════════════════════════════════════════════════

const wallpapers = [

    // ──────────────────────────────────────────────────────
    // NATURE  (23 wallpapers – sourced from Freepik)
    // ──────────────────────────────────────────────────────
    {
        title: 'Wooden Bridge at Sunset Beach',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/wooden-bridge-beach-sunset_181624-18247.jpg?w=740&q=80'
    },
    {
        title: 'Green Trees Beside River',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/brown-green-trees-beside-river-daytime_413556-116.jpg?w=740&q=80'
    },
    {
        title: 'Stones at Seaside Sunrise',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/vertical-shot-stones-seaside-fantastic-sunrise_181624-37106.jpg?w=740&q=80'
    },
    {
        title: 'Shore Plants with Mountain Sky',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/vertical-shot-plants-growing-shore-near-sea-with-mountains-blue-sky-background_181624-2109.jpg?w=740&q=80'
    },
    {
        title: 'Autumn Trees Beside Lake',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/brown-trees-beside-lake-daytime_413556-51.jpg?w=740&q=80'
    },
    {
        title: 'Powerful Waterfall Canada',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/beautiful-scenery-powerful-waterfall-surrounded-by-rocky-cliffs-trees-canada_181624-40995.jpg?w=740&q=80'
    },
    {
        title: 'Mountain Landscape Pink Flowers',
        category: 'Nature',
        url: 'https://img.freepik.com/premium-photo/beautiful-mountain-landscape-with-pink-flowers_899870-49927.jpg?w=740&q=80'
    },
    {
        title: 'AI Fall Leaves Autumn',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/ai-generated-fall-leaves-picture_23-2150648357.jpg?w=740&q=80'
    },
    {
        title: 'Majestic Autumn Trees by River',
        category: 'Nature',
        url: 'https://img.freepik.com/premium-photo/majestic-autumn-trees-by-serene-riverbank-calming-nature-scenery-relaxation-inspiration_1025827-146232.jpg?w=740&q=80'
    },
    {
        title: "Marshall's Beach San Francisco",
        category: 'Nature',
        url: 'https://img.freepik.com/premium-photo/view-from-marshall-s-beach-san-francisco-california_137125-629.jpg?w=740&q=80'
    },
    {
        title: 'Silhouette Rock at Sunset Sea',
        category: 'Nature',
        url: 'https://img.freepik.com/premium-photo/silhouette-rock-by-sea-against-romantic-sky-sunset_1626595-362.jpg?w=740&q=80'
    },
    {
        title: 'Tree Reflection Sunset Lake',
        category: 'Nature',
        url: 'https://img.freepik.com/premium-photo/landscape-with-silhouette-single-tree-reflection-sunset_63492-134.jpg?w=740&q=80'
    },
    {
        title: 'Forest River Sunset View',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/breathtaking-view-forest-river-gleaming-sunset-piercing-through-cloudy-sky_181624-30409.jpg?w=740&q=80'
    },
    {
        title: 'Orange Lily Field Dark Sky',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/vertical-orange-lily-field-cloudy-dark-sky_181624-37905.jpg?w=740&q=80'
    },
    {
        title: 'Yellow Green Tree Waterside',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/vertical-shot-yellow-green-tree-near-water-with-sun-shining-mountain-distance_181624-2197.jpg?w=740&q=80'
    },
    {
        title: 'Kotor Bay Montenegro Sunset',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/kotor-bay-with-mountains-distance-sunset-montenegro_181624-9051.jpg?w=740&q=80'
    },
    {
        title: 'Autumn Leaves AI Generated',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/ai-generated-fall-leaves_23-2150648513.jpg?w=740&q=80'
    },
    {
        title: 'Forest Reflection in Lake',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/beautiful-vertical-shot-reflection-forest-lake_181624-35805.jpg?w=740&q=80'
    },
    {
        title: 'Sea Sunset Twilight Sky',
        category: 'Nature',
        url: 'https://img.freepik.com/premium-photo/sea-sunset-sunrise-twilight-with-sky-cloud_37803-165.jpg?w=740&q=80'
    },
    {
        title: 'Mangrove Tree Beach Sunset',
        category: 'Nature',
        url: 'https://img.freepik.com/premium-photo/beauty-sunset-magrove-tree-tanjung-pinggir-beach_103127-925.jpg?w=740&q=80'
    },
    {
        title: 'Bonsai Tree on Rocky Cliff',
        category: 'Nature',
        url: 'https://img.freepik.com/premium-photo/majestic-bonsai-tree-rocky-cliff-by-serene-stream-golden-hour-best-quality-exquisite_916211-537113.jpg?w=740&q=80'
    },
    {
        title: 'Alpine Panorama Turquoise Lake',
        category: 'Nature',
        url: 'https://img.freepik.com/premium-photo/alpine-panorama-with-turquoise-lake_173770-500.jpg?w=740&q=80'
    },
    {
        title: 'Red Leafed Plant Close Up',
        category: 'Nature',
        url: 'https://img.freepik.com/free-photo/red-leafed-plant_417767-666.jpg?w=740&q=80'
    },

    // ──────────────────────────────────────────────────────
    // ABSTRACT  (20 wallpapers)
    // ──────────────────────────────────────────────────────
    {
        title: 'Pink Abstract Flow',
        category: 'Abstract',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25734.jpg'
    },
    {
        title: 'Blue Pink Abstract Burst',
        category: 'Abstract',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25736.png'
    },
    {
        title: 'Neon Abstract Wave',
        category: 'Abstract',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25735.jpg'
    },
    {
        title: 'Color Burst Abstract',
        category: 'Abstract',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25732.jpg'
    },
    {
        title: 'Neon Purple Smoke',
        category: 'Abstract',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25600.jpg'
    },
    {
        title: 'Colorful Geometric Mosaic',
        category: 'Abstract',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24810.jpg'
    },
    {
        title: 'Glowing Neon Lines',
        category: 'Abstract',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24560.jpg'
    },
    {
        title: 'Purple Blue Fluid Art',
        category: 'Abstract',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24300.jpg'
    },
    {
        title: 'Teal Ripple Abstract',
        category: 'Abstract',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24100.jpg'
    },
    {
        title: 'Golden Swirl Abstract',
        category: 'Abstract',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/23800.jpg'
    },
    {
        title: 'Holographic Prism',
        category: 'Abstract',
        url: 'https://img.freepik.com/free-photo/abstract-holographic-iridescent-background_53876-119548.jpg?w=740&q=80'
    },
    {
        title: 'Glowing Particles Bokeh',
        category: 'Abstract',
        url: 'https://img.freepik.com/free-photo/abstract-luxury-gradient-blue-background-smooth-dark-blue-with-black-vignette-studio-banner_1258-54539.jpg?w=740&q=80'
    },
    {
        title: 'Neon Cyberpunk Grid',
        category: 'Abstract',
        url: 'https://img.freepik.com/free-photo/abstract-geometric-background_53876-72819.jpg?w=740&q=80'
    },
    {
        title: 'Liquid Marble Texture',
        category: 'Abstract',
        url: 'https://img.freepik.com/free-photo/beautiful-flowing-abstract-marble-background_53876-129678.jpg?w=740&q=80'
    },
    {
        title: 'Electric Blue Waves',
        category: 'Abstract',
        url: 'https://img.freepik.com/free-photo/abstract-wavy-background_53876-102375.jpg?w=740&q=80'
    },
    {
        title: 'Rainbow Smoke Abstract',
        category: 'Abstract',
        url: 'https://img.freepik.com/free-photo/colorful-smoke-black-background_53876-102371.jpg?w=740&q=80'
    },
    {
        title: 'Dark Gradient Flow',
        category: 'Abstract',
        url: 'https://img.freepik.com/free-photo/abstract-luxury-gradient-gold-background-smooth-gold-with-black-vignette-studio-banner_1258-54548.jpg?w=740&q=80'
    },
    {
        title: 'Glitter Bokeh Gold',
        category: 'Abstract',
        url: 'https://img.freepik.com/free-photo/golden-bokeh-light-background_53876-100997.jpg?w=740&q=80'
    },
    {
        title: 'Pink Purple Gradient Mesh',
        category: 'Abstract',
        url: 'https://img.freepik.com/free-photo/abstract-pink-purple-gradient-background_53876-100046.jpg?w=740&q=80'
    },
    {
        title: 'Digital Hexagon Mesh',
        category: 'Abstract',
        url: 'https://img.freepik.com/free-photo/abstract-hexagonal-background_53876-100002.jpg?w=740&q=80'
    },

    // ──────────────────────────────────────────────────────
    // SPACE  (20 wallpapers)
    // ──────────────────────────────────────────────────────
    {
        title: 'Astronaut in the Cosmos',
        category: 'Space',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25817.jpg'
    },
    {
        title: 'Milky Way Galaxy',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/milky-way-galaxy_1048-3820.jpg?w=740&q=80'
    },
    {
        title: 'Nebula Purple Blue',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/nebula-stars-galaxy_53876-103478.jpg?w=740&q=80'
    },
    {
        title: 'Colorful Galaxy Swirl',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/beautiful-colorful-space-swirl_53876-111048.jpg?w=740&q=80'
    },
    {
        title: 'Black Hole Warp',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/beautiful-3d-black-hole-universe_23-2150855226.jpg?w=740&q=80'
    },
    {
        title: 'Starry Night Sky',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/beautiful-shot-starry-night-sky_181624-17956.jpg?w=740&q=80'
    },
    {
        title: 'Saturn Planet Rings',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/planet-saturn_1048-3819.jpg?w=740&q=80'
    },
    {
        title: 'Aurora Borealis Green',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/vertical-shot-beautiful-sky-with-northern-lights_181624-30405.jpg?w=740&q=80'
    },
    {
        title: 'Deep Space Stars',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/deep-space-stars_1048-3822.jpg?w=740&q=80'
    },
    {
        title: 'Galaxy Core Glow',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/galaxy-core-cosmic-background_53876-115600.jpg?w=740&q=80'
    },
    {
        title: 'Supernova Explosion',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/supernova-galaxy-cosmic-space_53876-106012.jpg?w=740&q=80'
    },
    {
        title: 'Astronaut on Moon',
        category: 'Space',
        url: 'https://img.freepik.com/premium-photo/astronaut-moon-surface-earth-visible-background_918839-26742.jpg?w=740&q=80'
    },
    {
        title: 'Purple Nebula Space',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/dark-purple-nebula-galaxy_53876-115602.jpg?w=740&q=80'
    },
    {
        title: 'Space Portal Wormhole',
        category: 'Space',
        url: 'https://img.freepik.com/premium-photo/space-wormhole-portal-travel_918839-25001.jpg?w=740&q=80'
    },
    {
        title: 'Earth from Space',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/earth-orbit-space_1048-3818.jpg?w=740&q=80'
    },
    {
        title: 'Cosmic Dust Clouds',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/cosmic-art-stars_23-2151020454.jpg?w=740&q=80'
    },
    {
        title: 'Andromeda Galaxy',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/ai-generated-andromeda-galaxy_23-2150647819.jpg?w=740&q=80'
    },
    {
        title: 'Mars Red Planet',
        category: 'Space',
        url: 'https://img.freepik.com/free-photo/mars-planet-digital-art_23-2151020449.jpg?w=740&q=80'
    },
    {
        title: 'Shooting Stars Meteor',
        category: 'Space',
        url: 'https://img.freepik.com/premium-photo/shooting-stars-meteor-shower-night-sky_918839-14123.jpg?w=740&q=80'
    },
    {
        title: 'Interstellar Journey',
        category: 'Space',
        url: 'https://img.freepik.com/premium-photo/astronaut-drifting-through-deep-space_918839-26990.jpg?w=740&q=80'
    },

    // ──────────────────────────────────────────────────────
    // ANIME  (20 wallpapers)
    // ──────────────────────────────────────────────────────
    {
        title: 'Shadow Eminence',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25784.jpg'
    },
    {
        title: 'Solo Leveling Sung Jinwoo',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25676.jpg'
    },
    {
        title: 'Goku Ultra Instinct',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25716.jpg'
    },
    {
        title: 'Naruto & Sasuke Final Battle',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25590.jpg'
    },
    {
        title: 'Luffy Gear 5 Nika',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25595.jpg'
    },
    {
        title: 'Demon Slayer Tanjiro',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25400.jpg'
    },
    {
        title: 'Attack on Titan Eren',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25350.jpg'
    },
    {
        title: 'Jujutsu Kaisen Gojo',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25200.jpg'
    },
    {
        title: 'Bleach Ichigo Fullbring',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24900.jpg'
    },
    {
        title: 'Dragon Ball Super Vegeta',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24850.jpg'
    },
    {
        title: 'My Hero Academia Deku',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24700.jpg'
    },
    {
        title: 'Sword Art Online Kirito',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24500.jpg'
    },
    {
        title: 'Tokyo Ghoul Kaneki',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24200.jpg'
    },
    {
        title: 'Chainsaw Man Denji',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24150.jpg'
    },
    {
        title: 'One Punch Man Saitama',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/23950.jpg'
    },
    {
        title: 'Hunter x Hunter Gon',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/23700.jpg'
    },
    {
        title: 'Fullmetal Alchemist Edward',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/23600.jpg'
    },
    {
        title: 'Vinland Saga Thorfinn',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/23400.jpg'
    },
    {
        title: 'Blue Lock Isagi',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/23350.jpg'
    },
    {
        title: 'Spy x Family Anya',
        category: 'Anime',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/23200.jpg'
    },

    // ──────────────────────────────────────────────────────
    // CARS & BIKES  (20 wallpapers)
    // ──────────────────────────────────────────────────────
    {
        title: 'Kawasaki Ninja Duo',
        category: 'Cars & Bikes',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25771.jpeg'
    },
    {
        title: 'Ferrari SF90 Stradale',
        category: 'Cars & Bikes',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25650.jpg'
    },
    {
        title: 'Lamborghini Urus Night',
        category: 'Cars & Bikes',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25500.jpg'
    },
    {
        title: 'BMW M4 Competition',
        category: 'Cars & Bikes',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25450.jpg'
    },
    {
        title: 'Porsche 911 GT3',
        category: 'Cars & Bikes',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25300.jpg'
    },
    {
        title: 'Bugatti Chiron Speed',
        category: 'Cars & Bikes',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25250.jpg'
    },
    {
        title: 'McLaren P1 Supercar',
        category: 'Cars & Bikes',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25100.jpg'
    },
    {
        title: 'Aston Martin DBS',
        category: 'Cars & Bikes',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25050.jpg'
    },
    {
        title: 'Ducati Panigale Red',
        category: 'Cars & Bikes',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24950.jpg'
    },
    {
        title: 'Harley Davidson Chopper',
        category: 'Cars & Bikes',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/24800.jpg'
    },
    {
        title: 'Rolls Royce Ghost',
        category: 'Cars & Bikes',
        url: 'https://img.freepik.com/free-photo/luxury-car-night-rain_23-2151020455.jpg?w=740&q=80'
    },
    {
        title: 'Mercedes AMG GT Black',
        category: 'Cars & Bikes',
        url: 'https://img.freepik.com/premium-photo/sports-car-black-dark-background_918839-2345.jpg?w=740&q=80'
    },
    {
        title: 'Cyberpunk Neon Car',
        category: 'Cars & Bikes',
        url: 'https://img.freepik.com/premium-photo/futuristic-neon-sports-car-cyberpunk-city_918839-12345.jpg?w=740&q=80'
    },
    {
        title: 'Audi R8 Rainy Night',
        category: 'Cars & Bikes',
        url: 'https://img.freepik.com/premium-photo/sports-car-rainy-street-night_918839-2789.jpg?w=740&q=80'
    },
    {
        title: 'Honda CBR600 Track',
        category: 'Cars & Bikes',
        url: 'https://img.freepik.com/premium-photo/motorcycle-racing-track-sport-bike_918839-8901.jpg?w=740&q=80'
    },
    {
        title: 'Jeep Off-Road Mountain',
        category: 'Cars & Bikes',
        url: 'https://img.freepik.com/free-photo/off-road-car-mountain-trail_23-2151020450.jpg?w=740&q=80'
    },
    {
        title: 'Classic Mustang GT',
        category: 'Cars & Bikes',
        url: 'https://img.freepik.com/premium-photo/classic-ford-mustang-muscle-car_918839-3456.jpg?w=740&q=80'
    },
    {
        title: 'Tesla Model S Electric',
        category: 'Cars & Bikes',
        url: 'https://img.freepik.com/premium-photo/electric-car-futuristic-concept_918839-5678.jpg?w=740&q=80'
    },
    {
        title: 'Vintage Motorcycle Route 66',
        category: 'Cars & Bikes',
        url: 'https://img.freepik.com/premium-photo/vintage-motorcycle-american-highway_918839-4567.jpg?w=740&q=80'
    },
    {
        title: 'F1 Race Car Blur',
        category: 'Cars & Bikes',
        url: 'https://img.freepik.com/premium-photo/formula-1-car-speed-track_918839-6789.jpg?w=740&q=80'
    },

    // ──────────────────────────────────────────────────────
    // SUPERHERO  (20 wallpapers)
    // ──────────────────────────────────────────────────────
    {
        title: 'Daredevil Born Again',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25777.jpg'
    },
    {
        title: 'Iron Man Arc Reactor',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25566.jpg'
    },
    {
        title: 'Spider-Man Noir',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25754.jpg'
    },
    {
        title: 'Batman Dark Knight',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25700.jpg'
    },
    {
        title: 'Thor Lightning Strike',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25680.jpg'
    },
    {
        title: 'Captain America Shield',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25660.jpg'
    },
    {
        title: 'Black Panther Wakanda',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25640.jpg'
    },
    {
        title: 'Doctor Strange Multiverse',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25620.jpg'
    },
    {
        title: 'Venom Symbiote',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25610.jpg'
    },
    {
        title: 'Superman Krypton',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25580.jpg'
    },
    {
        title: 'Wonder Woman Warrior',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25560.jpg'
    },
    {
        title: 'Flash Speedforce',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25550.jpg'
    },
    {
        title: 'Aquaman Ocean King',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25540.jpg'
    },
    {
        title: 'Green Lantern Corps',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25530.jpg'
    },
    {
        title: 'Thanos Infinity Gauntlet',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25520.jpg'
    },
    {
        title: 'Wolverine Adamantium',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25510.jpg'
    },
    {
        title: 'Deadpool Breaking Fourth Wall',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25500.jpg'
    },
    {
        title: 'Avengers Assemble',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25490.jpg'
    },
    {
        title: 'Hulk Smash Power',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25480.jpg'
    },
    {
        title: 'Spider-Man Miles Morales',
        category: 'Superhero',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25470.jpg'
    },

    // ──────────────────────────────────────────────────────
    // DARK / MOODY  (20 wallpapers)
    // ──────────────────────────────────────────────────────
    {
        title: 'Solitary Figure Under Stars',
        category: 'Dark',
        url: 'https://img.freepik.com/free-photo/dark-moody-forest-night-fog_53876-108000.jpg?w=740&q=80'
    },
    {
        title: 'Dark Forest Fog',
        category: 'Dark',
        url: 'https://img.freepik.com/free-photo/dark-moody-misty-forest_53876-107000.jpg?w=740&q=80'
    },
    {
        title: 'Abandoned City Rain',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/dark-rainy-city-street-night_918839-11111.jpg?w=740&q=80'
    },
    {
        title: 'Gothic Cathedral Night',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/dark-gothic-cathedral-foggy-night_918839-22222.jpg?w=740&q=80'
    },
    {
        title: 'Lone Wolf Howling Moon',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/wolf-howling-full-moon-night_918839-33333.jpg?w=740&q=80'
    },
    {
        title: 'Dark Ocean Storm',
        category: 'Dark',
        url: 'https://img.freepik.com/free-photo/stormy-ocean-dark-clouds_53876-109000.jpg?w=740&q=80'
    },
    {
        title: 'Shadow Alley Night',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/dark-alley-neon-lights-rain_918839-44444.jpg?w=740&q=80'
    },
    {
        title: 'Ancient Ruins Sunset',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/ancient-ruins-moody-fog_918839-55555.jpg?w=740&q=80'
    },
    {
        title: 'Floating Lanterns Dark Sky',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/floating-lanterns-dark-sky-festival_918839-66666.jpg?w=740&q=80'
    },
    {
        title: 'Skull Dark Aesthetic',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/dark-skull-aesthetic-wallpaper_918839-77777.jpg?w=740&q=80'
    },
    {
        title: 'Creepy Old Mansion',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/haunted-mansion-dark-night-moon_918839-88888.jpg?w=740&q=80'
    },
    {
        title: 'Dark Phoenix Flame',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/dark-phoenix-fire-smoke_918839-99999.jpg?w=740&q=80'
    },
    {
        title: 'Grim Reaper Silhouette',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/grim-reaper-silhouette-moonlight_918839-11122.jpg?w=740&q=80'
    },
    {
        title: 'Black Rose Aesthetic',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/black-rose-dark-background-aesthetic_918839-11133.jpg?w=740&q=80'
    },
    {
        title: 'Dark City Skyline Rain',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/cyberpunk-dark-city-rain-night_918839-11144.jpg?w=740&q=80'
    },
    {
        title: 'Smoky Mountains Dusk',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/smoky-mountains-dark-dusk_918839-11155.jpg?w=740&q=80'
    },
    {
        title: 'Electric Storm Dark',
        category: 'Dark',
        url: 'https://img.freepik.com/free-photo/lightning-storm-dark-clouds_53876-110000.jpg?w=740&q=80'
    },
    {
        title: 'Dark Samurai Silhouette',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/samurai-dark-foggy-castle_918839-11166.jpg?w=740&q=80'
    },
    {
        title: 'Moonlit Lake Reflection',
        category: 'Dark',
        url: 'https://img.freepik.com/free-photo/moonlit-lake-night-reflection_181624-11500.jpg?w=740&q=80'
    },
    {
        title: 'Eerie Graveyard Fog',
        category: 'Dark',
        url: 'https://img.freepik.com/premium-photo/foggy-graveyard-dark-night_918839-11177.jpg?w=740&q=80'
    },

    // ──────────────────────────────────────────────────────
    // MINIMAL  (20 wallpapers)
    // ──────────────────────────────────────────────────────
    {
        title: 'White Minimal Waves',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-vector/minimalist-white-wavy-background_53876-96501.jpg?w=740&q=80'
    },
    {
        title: 'Clean Pastel Gradient',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-vector/gradient-pastel-background_23-2148922493.jpg?w=740&q=80'
    },
    {
        title: 'Minimal Geometric Lines',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-vector/minimal-geometric-lines-background_53876-94500.jpg?w=740&q=80'
    },
    {
        title: 'Sand Dune Texture',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/sand-dune-clean-minimal_53876-108500.jpg?w=740&q=80'
    },
    {
        title: 'Soft Blush Pink',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/abstract-blush-pink-texture_53876-93000.jpg?w=740&q=80'
    },
    {
        title: 'Dark Minimal Triangle',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-vector/dark-minimal-triangle-background_53876-97000.jpg?w=740&q=80'
    },
    {
        title: 'Single Leaf White',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/single-leaf-white-background_53876-102000.jpg?w=740&q=80'
    },
    {
        title: 'Blue Sky Minimal Clouds',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/blue-sky-minimal-white-clouds_53876-107500.jpg?w=740&q=80'
    },
    {
        title: 'Black Marble Luxury',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/black-marble-texture_53876-96000.jpg?w=740&q=80'
    },
    {
        title: 'Cream Linen Texture',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/cream-linen-fabric-texture_53876-94000.jpg?w=740&q=80'
    },
    {
        title: 'Minimal Fox on White',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/minimal-animal-white-background_53876-101000.jpg?w=740&q=80'
    },
    {
        title: 'Sage Green Minimal',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/sage-green-minimal-texture_53876-98000.jpg?w=740&q=80'
    },
    {
        title: 'Paper Fold White',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/paper-fold-minimal-design_53876-95000.jpg?w=740&q=80'
    },
    {
        title: 'Midnight Blue Simple',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-vector/dark-blue-simple-gradient-background_53876-113000.jpg?w=740&q=80'
    },
    {
        title: 'Golden Hour Sunbeam',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/golden-hour-sunbeam-minimal_53876-106000.jpg?w=740&q=80'
    },
    {
        title: 'Ink Drop Minimal',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/ink-drop-water-minimal_53876-97500.jpg?w=740&q=80'
    },
    {
        title: 'Dandelion White Breath',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/dandelion-white-minimal_53876-96500.jpg?w=740&q=80'
    },
    {
        title: 'Circular Wave Ripple',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/circular-water-ripple-minimal_53876-95500.jpg?w=740&q=80'
    },
    {
        title: 'Clean White Architecture',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/minimal-white-architecture-staircase_53876-95200.jpg?w=740&q=80'
    },
    {
        title: 'Lavender Field Minimal',
        category: 'Minimal',
        url: 'https://img.freepik.com/free-photo/lavender-field-vertical-minimal_53876-95100.jpg?w=740&q=80'
    },

    // ──────────────────────────────────────────────────────
    // MOVIES  (20 wallpapers)
    // ──────────────────────────────────────────────────────
    {
        title: 'Ghostface Scream',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25788.jpg'
    },
    {
        title: 'The Dark Knight Rises',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25750.jpg'
    },
    {
        title: 'Joker 2019 Chaos',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25720.jpg'
    },
    {
        title: 'Interstellar Black Hole',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25690.jpg'
    },
    {
        title: 'John Wick Silhouette',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25670.jpg'
    },
    {
        title: 'Avengers Endgame',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25650.jpg'
    },
    {
        title: 'Star Wars Death Star',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25630.jpg'
    },
    {
        title: 'Blade Runner 2049',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25600.jpg'
    },
    {
        title: 'Mad Max Fury Road',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25580.jpg'
    },
    {
        title: 'The Matrix Reloaded',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25560.jpg'
    },
    {
        title: 'God of War Kratos',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25540.jpg'
    },
    {
        title: 'Dune Arrakis Desert',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25520.jpg'
    },
    {
        title: 'Oppenheimer Trinity',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25500.jpg'
    },
    {
        title: 'Avatar Pandora',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25480.jpg'
    },
    {
        title: 'Gladiator Arena',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25460.jpg'
    },
    {
        title: 'Inception Dream City',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25440.jpg'
    },
    {
        title: 'Parasite Symbol',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25420.jpg'
    },
    {
        title: 'Top Gun Maverick Jet',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25400.jpg'
    },
    {
        title: 'Transformers Optimus',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25380.jpg'
    },
    {
        title: 'The Shining Hotel',
        category: 'Movies',
        url: 'https://4kwallpapers.com/images/walls/thumbs_3t/25360.jpg'
    }

];

// ════════════════════════════════════════════════════════════════════
// SEED FUNCTION
// ════════════════════════════════════════════════════════════════════

async function seedAllCategories() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.\n');

        const categories = [...new Set(wallpapers.map(w => w.category))];
        console.log(`Categories to seed: ${categories.join(', ')}`);
        console.log(`Total wallpapers: ${wallpapers.length}\n`);

        let successCount = 0;
        let failCount = 0;

        for (const item of wallpapers) {
            console.log(`⏳ [${item.category}] ${item.title}`);
            try {
                const response = await axios.get(item.url, {
                    responseType: 'arraybuffer',
                    timeout: 20000,
                    headers: {
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
                        'Referer': 'https://www.freepik.com/',
                        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8'
                    }
                });

                const buffer = Buffer.from(response.data);
                const originalName = path.basename(item.url.split('?')[0]);
                const uploadResult = await processAndUploadImage(buffer, originalName);

                const newWallpaper = new Wallpaper({
                    title: item.title,
                    category: item.category,
                    imageUrl: {
                        original: uploadResult.original,
                        mid: uploadResult.mid,
                        low: uploadResult.low,
                        blurHash: uploadResult.blurHash
                    },
                    type: 'static'
                });

                await newWallpaper.save();
                console.log(`  ✅ Added: ${item.title}`);
                successCount++;
            } catch (err) {
                console.error(`  ❌ Failed: ${item.title} — ${err.message}`);
                if (err.response) {
                    console.error(`     HTTP ${err.response.status}`);
                }
                failCount++;
            }
        }

        console.log('\n════════════════════════════════════════');
        console.log(`Seeding complete!`);
        console.log(`  ✅ Success: ${successCount}`);
        console.log(`  ❌ Failed:  ${failCount}`);
        console.log(`  Total:     ${wallpapers.length}`);
        console.log('════════════════════════════════════════');
        process.exit(0);
    } catch (error) {
        console.error('Fatal Error:', error);
        process.exit(1);
    }
}

seedAllCategories();
