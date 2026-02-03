const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Wallpaper = require('../models/Wallpaper');

// Load env vars
dotenv.config({ path: path.join(__dirname, '../.env') });

const superheroUrls = [
    'https://tse4.mm.bing.net/th/id/OIP.yAjB4Ql7oF2sglV7zPrpnwHaNK?rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpaperaccess.com/full/5051464.jpg',
    'https://wallpaperaccess.com/full/6117774.jpg',
    'https://media.livewallpapers.com/images/high/chibi-superhero-mobile-wallpaper-2.webp',
    'https://tse3.mm.bing.net/th/id/OIP.ouGwR4lmyCmJ9fJR79VxXQHaNK?w=736&h=1308&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://wallpapercave.com/wp/wp14475187.jpg',
    'https://media.livewallpapers.com/images/high/vibrant-superhero-mobile-wallpaper-15.webp',
    'https://tse3.mm.bing.net/th/id/OIP.Z-eevJf8DYs9e0woMWJcWQHaO0?w=768&h=1536&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.lqXESD3rBJtCgzkslthrCgHaQC?w=1125&h=2436&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.NuTCx03UvRQ0eHDNtlxPuQHaNK?w=800&h=1422&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.bUgT4t2CfXgnAXPBLl-Z5QHaNK?w=748&h=1330&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://media.livewallpapers.com/images/high/vibrant-superhero-mobile-wallpaper-36.webp',
    'https://media.livewallpapers.com/images/high/dynamic-superhero-mobile-wallpaper-8.webp',
    'https://wallpapers.com/images/hd/the-mutants-superhero-iphone-m68kcx356dbnrwh1.jpg',
    'https://tse2.mm.bing.net/th/id/OIP.g1elbRYiN5kVY6GdsGiS5gHaNK?w=1440&h=2560&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://e1.pxfuel.com/desktop-wallpaper/359/596/desktop-wallpaper-superhero-marvel-comics-iron-man-and-iron-man-mobile.jpg',
    'https://media.livewallpapers.com/images/high/animated-superhero-mobile-wallpaper-1.webp',
    'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/98857928-ca57-4269-bfa5-cdd1f1fddb6a/diquug5-bfbc7c7e-cead-4d1f-ba07-84d4530dbb70.jpg/v1/fill/w_894,h_894,q_70,strp/evil_super_kim_possible_by_dougverse_diquug5-pre.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MjA0OCIsInBhdGgiOiJcL2ZcLzk4ODU3OTI4LWNhNTctNDI2OS1iZmE1LWNkZDFmMWZkZGI2YVwvZGlxdXVnNS1iZmJjN2M3ZS1jZWFkLTRkMWYtYmEwNy04NGQ0NTMwZGJiNzAuanBnIiwid2lkdGgiOiI8PTIwNDgifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6aW1hZ2Uub3BlcmF0aW9ucyJdfQ.J3juE6sWM500grnfN-yIRpw3s_6Cv1Hc-D-gGAwXfRo',
    'https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto,q_auto,f_auto/gigs2/345406740/original/e6284d50807c1cf4fc4c8be263d0ec5db4c42e2e/design-a-superhero-character.png',
    'https://tse1.explicit.bing.net/th/id/OIP.lqBdxI2W92mI-AuDChfP3gHaEw?w=1400&h=900&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://media.livewallpapers.com/images/high/dynamic-superhero-mobile-wallpaper-49.webp',
    'https://media.livewallpapers.com/images/high/dynamic-superhero-mobile-wallpaper-96.webp',
    'https://wallpaperaccess.com/full/874976.jpg',
    'https://wallpapercave.com/wp/wp14798419.webp',
    'https://tse1.mm.bing.net/th/id/OIP.DKKouWzFgZpye-InTB9ggwHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://media.livewallpapers.com/images/high/vibrant-superhero-mobile-wallpaper-1.webp',
    'https://tse1.mm.bing.net/th/id/OIP.K8IczGCB3Ra82ehyGkM6KAHaQD?w=1463&h=3171&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.Ku0x59yCuldpykPmO5RoZwAAAA?w=403&h=838&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse2.mm.bing.net/th/id/OIP.Q8-rcIJYr6ypemHqG0Ki0gHaNK?w=748&h=1330&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse4.mm.bing.net/th/id/OIP.zgzHSE6T-lFf2ieD9wDhzgHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://tse1.mm.bing.net/th/id/OIP.9rXaDWGIvUtXqeDmZ4IePwHaNK?w=1080&h=1920&rs=1&pid=ImgDetMain&o=7&rm=3',
    'https://i.ytimg.com/vi/eWLOTzg3pb4/oar2.jpg?sqp=-oaymwEkCJUDENAFSFqQAgHyq4qpAxMIARUAAAAAJQAAyEI9AICiQ3gB&rs=AOn4CLCxIPhw6-eyKV4Gzu5qvZ7Jh02M_g'
];

async function addSuperheroWallpapers() {
    try {
        console.log('Connecting to MongoDB...');
        if (!process.env.MONGO_URI) {
            throw new Error('MONGO_URI is not defined in .env file');
        }
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected successfully.');

        const category = 'Superhero';

        console.log(`Deleting existing wallpapers in category: ${category}...`);
        const deleteResult = await Wallpaper.deleteMany({ category: category });
        console.log(`Deleted ${deleteResult.deletedCount} old wallpapers.`);

        const newWallpapers = superheroUrls.map((url, index) => ({
            title: `Superhero Power ${index + 1}`,
            category: category,
            imageUrl: {
                original: url,
                mid: url,
                low: url
            },
            createdAt: new Date()
        }));

        console.log(`Inserting ${newWallpapers.length} new superhero wallpapers...`);
        await Wallpaper.insertMany(newWallpapers);

        console.log('Successfully updated Superhero category!');
        process.exit(0);
    } catch (error) {
        console.error('Error updating superhero category:', error);
        process.exit(1);
    }
}

addSuperheroWallpapers();
