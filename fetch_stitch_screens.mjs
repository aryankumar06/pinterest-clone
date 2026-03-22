import { stitch } from "@google/stitch-sdk";
import { writeFileSync, mkdirSync } from "fs";
import { join } from "path";
import https from "https";
import http from "http";
import fs from "fs";

// Set API key
// The Stitch SDK automatically reads process.env.STITCH_API_KEY if set.
// Ensure STITCH_API_KEY is set in your environment, e.g., via: $env:STITCH_API_KEY="your_key"

const PROJECT_ID = "3515922487242657693";

const screens = [
    { name: "updated_profile_boards", label: "Updated Profile & Boards", id: "c27357ca906446cab565138999ee0eb7" },
    { name: "profile_boards", label: "Profile & Boards", id: "d5dafe4b474748479c11eb4244a425f9" },
    { name: "create_pin", label: "Create Pin", id: "57fef801b2a54e9aae5bfb0289bfa898" },
    { name: "explore", label: "Explore", id: "78679881e5df4560952367be93e3ce11" },
    { name: "home_feed", label: "Home Feed", id: "20d0620ea47646babf57ed2bb07011ff" },
];

/** Download URL to a file, following redirects */
function downloadFile(url, dest) {
    return new Promise((resolve, reject) => {
        const proto = url.startsWith("https") ? https : http;
        const file = fs.createWriteStream(dest);

        const request = proto.get(url, (response) => {
            if (response.statusCode === 302 || response.statusCode === 301) {
                file.close();
                try { fs.unlinkSync(dest); } catch { }
                downloadFile(response.headers.location, dest).then(resolve).catch(reject);
                return;
            }
            response.pipe(file);
            file.on("finish", () => { file.close(); resolve(); });
            response.on("error", reject);
        });

        request.on("error", (err) => {
            try { fs.unlinkSync(dest); } catch { }
            reject(err);
        });
    });
}

/** Fetch text content from a URL, following redirects */
function fetchText(url) {
    return new Promise((resolve, reject) => {
        const proto = url.startsWith("https") ? https : http;

        proto.get(url, (response) => {
            if (response.statusCode === 302 || response.statusCode === 301) {
                fetchText(response.headers.location).then(resolve).catch(reject);
                return;
            }
            let data = "";
            response.setEncoding("utf8");
            response.on("data", (chunk) => { data += chunk; });
            response.on("end", () => resolve(data));
            response.on("error", reject);
        }).on("error", reject);
    });
}

async function main() {
    const project = stitch.project(PROJECT_ID);

    const outDir = "D:\\personal project\\pinterest-clone\\stitch_screens";
    mkdirSync(outDir, { recursive: true });

    console.log(`Output directory: ${outDir}\n`);

    for (const screen of screens) {
        console.log(`=== Fetching: ${screen.label} (${screen.id}) ===`);
        try {
            const s = await project.getScreen(screen.id);

            // Get HTML download URL, then fetch actual content
            const htmlUrl = await s.getHtml();
            console.log(`  🔗 HTML URL: ${htmlUrl}`);
            const htmlContent = await fetchText(htmlUrl);
            const htmlPath = join(outDir, `${screen.name}.html`);
            writeFileSync(htmlPath, htmlContent, "utf8");
            console.log(`  ✅ HTML saved (${htmlContent.length} chars)`);

            // Get image URL and download
            const imageUrl = await s.getImage();
            console.log(`  📸 Image URL: ${imageUrl}`);
            const imgPath = join(outDir, `${screen.name}.png`);
            await downloadFile(imageUrl, imgPath);
            const stat = fs.statSync(imgPath);
            console.log(`  ✅ Image saved (${stat.size} bytes)`);

        } catch (err) {
            console.error(`  ❌ Error: ${err.message || err}`);
            if (err.stack) console.error(err.stack);
        }
        console.log();
    }

    console.log("✅ All done!");
    process.exit(0);
}

main().catch(console.error);
