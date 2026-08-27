"use strict";

document.addEventListener("DOMContentLoaded", () => {
    const bloom = document.getElementById("bloom");

    if (!bloom) {
        return;
    }

    const center = bloom.querySelector(".bloom-center");
    const options = bloom.querySelector(".bloom-options");

    if (!center || !options) {
        return;
    }

    let isOpen = false;

    // ==================================================
    // BLOOM POSITIONING
    // ==================================================

    function positionBloomItems() {
        const items = Array.from(
            bloom.querySelectorAll("[data-bloom-item]")
        ).filter((item) => !item.hidden);

        const count = items.length;

        if (count === 0) {
            return;
        }

        const radius =
            Math.min(
                bloom.clientWidth,
                bloom.clientHeight
            ) * 0.30;

        const centerX = bloom.clientWidth / 2;
        const centerY = bloom.clientHeight / 2;

        items.forEach((item, index) => {
            const angle =
                (2 * Math.PI * index) / count -
                Math.PI / 2;

            item.style.left =
                `${centerX + radius * Math.cos(angle)}px`;

            item.style.top =
                `${centerY + radius * Math.sin(angle)}px`;
        });
    }


    // ==================================================
    // BLOOM STATE
    // ==================================================

    function setOpenState(open) {
        isOpen = Boolean(open);

        bloom.classList.toggle(
            "is-open",
            isOpen
        );

        bloom.dataset.state =
            isOpen ? "active" : "quiet";

        center.setAttribute(
            "aria-expanded",
            String(isOpen)
        );

        center.setAttribute(
            "aria-label",
            isOpen
                ? "Close primary exploration"
                : "Open primary exploration"
        );

        options.setAttribute(
            "aria-hidden",
            String(!isOpen)
        );
    }


    // ==================================================
    // CONTEXTUAL STATE
    // ==================================================

    function setContextualState() {
        bloom.dataset.state = "contextual";
    }


    // ==================================================
    // CONTEXT
    // ==================================================

    const currentContext = {
        area: "home",
        hasDataset: false,
        hasContent: false,
    };


    const contextCapabilities = {
        home: [
            "analyze",
            "explore",
            "explain",
        ],

        dataset: [
            "analyze",
            "compare",
            "explore",
            "explain",
        ],

        content: [
            "analyze",
            "compare",
            "explain",
        ],
    };


    // ==================================================
    // APPLY CONTEXT
    // ==================================================

    function applyContextCapabilities(capabilities) {
        const items = bloom.querySelectorAll(
            "[data-bloom-item]"
        );

        items.forEach((item) => {
            const capability =
                item.dataset.capability;

            item.hidden =
                !capabilities.includes(capability);
        });

        positionBloomItems();
    }


    let capabilities;

    if (currentContext.hasDataset) {
        capabilities =
            contextCapabilities.dataset;
    } else if (currentContext.hasContent) {
        capabilities =
            contextCapabilities.content;
    } else {
        capabilities =
            contextCapabilities[currentContext.area] || [];
    }


    applyContextCapabilities(capabilities);


    // ==================================================
    // CENTER OPEN / CLOSE
    // ==================================================

    center.addEventListener("click", () => {
        setOpenState(!isOpen);
    });


    // ==================================================
    // PRIMARY BLOOM OPTIONS
    // ==================================================

    const bloomItems = bloom.querySelectorAll(
        "[data-bloom-item]"
    );

    bloomItems.forEach((item) => {
        item.addEventListener("click", () => {
            setContextualState();
        });
    });


    // ==================================================
    // INITIAL STATE
    // ==================================================

    setOpenState(false);

    positionBloomItems();


    // ==================================================
    // RESPONSIVE POSITIONING
    // ==================================================

    window.addEventListener(
        "resize",
        positionBloomItems
    );
});