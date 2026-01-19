package tree_sitter_astra_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_astra "github.com/tree-sitter/tree-sitter-astra/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_astra.Language())
	if language == nil {
		t.Errorf("Error loading Astra HM gramar grammar")
	}
}
