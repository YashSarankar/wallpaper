const axios = require('axios');

const urls = [
    'https://www.freepik.com/free-ai-image/anime-moon-landscape_234119364.htm',
    'https://www.freepik.com/free-ai-image/anime-moon-landscape_234119425.htm',
    'https://www.freepik.com/free-ai-image/anime-landscape-person-traveling_94945469.htm',
    'https://www.freepik.com/free-ai-image/full-shot-ninja-wearing-equipment_81007612.htm',
    'https://www.freepik.com/free-ai-image/person-walking-alone-city-street_71936173.htm',
    'https://www.freepik.com/free-ai-image/anime-style-character-space_122499651.htm',
    'https://www.freepik.com/free-ai-image/anime-waterfall-landscape_417568937.htm',
    'https://www.freepik.com/free-ai-image/anime-style-boy-girl-couple_187468590.htm',
    'https://www.freepik.com/free-ai-image/nighttime-scene-with-girl-gazing-japanese-style-castle-moon_417568942.htm',
    'https://www.freepik.com/premium-ai-image/dynamic-illustration-basketball-player-doing-slam-dunk-against-vibrant-sky_272858796.htm',
    'https://www.freepik.com/free-ai-image/beautiful-clouds-digital-art_144644700.htm',
    'https://www.freepik.com/premium-ai-image/enchanting-nightscape-solitary-figure-starry-sky-with-ancient-temple_347358961.htm',
    'https://www.freepik.com/premium-photo/scenery-surreal-world-showing-man-walking-clouds-looking-upside-down-mountains-digital-art-style-illustration-painting_21171288.htm',
    'https://www.freepik.com/premium-ai-image/world-sea_205363503.htm',
    'https://www.freepik.com/premium-ai-image/dynamic-illustration-basketball-player-doing-slam-dunk-against-vibrant-sky_272859493.htm',
    'https://www.freepik.com/premium-ai-image/samurai-cartoon-toy-representation_253609292.htm',
    'https://www.freepik.com/free-ai-image/sunset-stroll-boy-cat-snowy-village_422336924.htm',
    'https://www.freepik.com/free-ai-image/digital-art-isolated-house_93658026.htm',
    'https://www.freepik.com/free-ai-image/beautiful-autumn-landscape_419928723.htm',
    'https://www.freepik.com/free-ai-image/lonely-walk-night-rain-soaked-alley-illustration_418149489.htm',
    'https://www.freepik.com/premium-ai-image/dynamic-illustration-basketball-player-doing-slam-dunk-against-vibrant-sky_272860832.htm',
    'https://www.freepik.com/premium-ai-image/silhouete-person-holding-cell-phone-outside-with-sunset_46815187.htm',
    'https://www.freepik.com/premium-ai-image/epic-fantasy-landscape-with-samurai-silhouette-sunset_347232458.htm',
    'https://www.freepik.com/free-ai-image/digital-art-isolated-house_93658014.htm',
    'https://www.freepik.com/free-ai-image/beauty-digital-art-through-immersive-experiences_138695817.htm',
    'https://www.freepik.com/free-ai-image/anime-moon-landscape_234131886.htm',
    'https://www.freepik.com/free-ai-image/demon-girl-glowing-forest_418346679.htm',
    'https://www.freepik.com/free-ai-image/halloween-scene-illustration-anime-style_299791551.htm',
    'https://www.freepik.com/premium-ai-image/serene-sunset-silhouette-reflective-moment-by-water_347360549.htm'
];

async function getFreepikData(url) {
    try {
        const response = await axios.get(url, {
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Referer': 'https://www.freepik.com/'
            }
        });
        const html = response.data;

        // Extract og:image
        const imageMatch = html.match(/property="og:image" content="([^"]+)"/);
        const titleMatch = html.match(/property="og:title" content="([^"]+)"/);

        if (imageMatch) {
            let imgUrl = imageMatch[1];
            // Append w=2000 for high quality
            if (!imgUrl.includes('?')) {
                imgUrl += '?w=2000';
            } else if (!imgUrl.includes('w=')) {
                imgUrl += '&w=2000';
            }

            let title = titleMatch ? titleMatch[1].split('|')[0].trim() : 'Anime Wallpaper';
            // Clean title from "Free AI Image |" or similar
            title = title.replace(/^Free Photo \| /, '').replace(/^Free AI Image \| /, '').replace(/^Premium AI Image \| /, '');

            return { title, url: imgUrl, category: 'Anime' };
        }
    } catch (err) {
        console.error(`Failed ${url}: ${err.message}`);
    }
    return null;
}

async function main() {
    const wallpapers = [];
    for (const url of urls) {
        const data = await getFreepikData(url);
        if (data) wallpapers.push(data);
        else console.error(`No data for ${url}`);
    }
    console.log(JSON.stringify(wallpapers, null, 2));
}

main();
