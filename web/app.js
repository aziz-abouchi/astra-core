d3.json("/api/egraph").then(data => {
    const svg = d3.select("#graph").append("svg").attr("width", 800).attr("height", 600);

    // Dessin des liens (Unions dans l'E-Graph)
    const link = svg.append("g").selectAll("line").data(data.links).enter().append("line");

    // Dessin des nœuds avec Halo d'incertitude
    const node = svg.append("g").selectAll("g").data(data.nodes).enter().append("g");

    node.append("circle")
        .attr("class", "uncertainty-halo")
        .attr("r", d => d.uncertainty * 50); // Taille proportionnelle à l'erreur

    node.append("circle")
        .attr("r", 5)
        .attr("fill", d => d.type === "Hole" ? "#ff4444" : "#44ff44");
});
