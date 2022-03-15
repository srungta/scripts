var open = require('open');
var urls = require("./urls");

const openUrls = (urls) => {
    for (let index = 0; index < urls.length; index++) {
        const element = urls[index];
        open(element);
    }
}

openUrls(urls.urls);