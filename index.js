const config = {
    load: async function (elmLoaded) {
        const app = await elmLoaded;
        console.log("App loaded", app);
    },
    flags: function () {
        console.log("----> Window width", window.innerWidth)
        return window.innerWidth;
    },
};
export default config;
