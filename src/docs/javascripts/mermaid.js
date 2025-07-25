// Mermaid.js configuration for diagrams
// This file configures Mermaid for rendering diagrams in the documentation

// Configure Mermaid settings
window.mermaidConfig = {
    theme: 'base',
    themeVariables: {
        primaryColor: '#2196F3',
        primaryTextColor: '#212121',
        primaryBorderColor: '#1976D2',
        lineColor: '#424242',
        secondaryColor: '#E3F2FD',
        tertiaryColor: '#BBDEFB'
    },
    startOnLoad: true,
    flowchart: {
        useMaxWidth: true,
        htmlLabels: true,
        curve: 'cardinal'
    },
    sequence: {
        diagramMarginX: 50,
        diagramMarginY: 10,
        actorMargin: 50,
        width: 150,
        height: 65,
        boxMargin: 10,
        boxTextMargin: 5,
        noteMargin: 10,
        messageMargin: 35,
        mirrorActors: true,
        bottomMarginAdj: 1,
        useMaxWidth: true,
        rightAngles: false,
        showSequenceNumbers: false
    },
    gantt: {
        titleTopMargin: 25,
        barHeight: 20,
        fontSizes: 13,
        sectionFontSize: 24,
        numberSectionStyles: 4,
        axisFormat: '%Y-%m-%d'
    }
};

// Initialize Mermaid when the document is ready
document.addEventListener('DOMContentLoaded', function() {
    if (typeof mermaid !== 'undefined') {
        mermaid.initialize(window.mermaidConfig);
    }
});
