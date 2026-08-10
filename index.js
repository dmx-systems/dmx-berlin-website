export default {
    load: async function (elmLoaded) {
        const app = await elmLoaded;
        console.log("App loaded", app);
        window.addEventListener('resize',
            () => app.ports.onResize.send(window.innerWidth)
        )
    },
    flags: function () {
        console.log("[dmx-berlin-website] Window width", window.innerWidth)
        return window.innerWidth;
    },
};
