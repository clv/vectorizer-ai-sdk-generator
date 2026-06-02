package main

import (
	"context"
	"fmt"
	"os"

	vectorizer "github.com/clv/vectorizer-go"
)

func main() {
	apiID := os.Getenv("VECTORIZER_API_ID")
	apiSecret := os.Getenv("VECTORIZER_API_SECRET")
	inputPath := getenv("VECTORIZER_INPUT", "example.png")
	outputPath := getenv("VECTORIZER_OUTPUT", "result.svg")

	image, err := os.Open(inputPath)
	if err != nil {
		panic(err)
	}

	ctx := context.WithValue(context.Background(), vectorizer.ContextBasicAuth, vectorizer.BasicAuth{
		UserName: apiID,
		Password: apiSecret,
	})

	client := vectorizer.NewAPIClient(vectorizer.NewConfiguration())
	result, _, err := client.VectorizationAPI.PostVectorize(ctx).
		Image(image).
		OutputFileFormat("svg").
		Execute()
	if err != nil {
		panic(err)
	}

	data, err := os.ReadFile(result.Name())
	if err != nil {
		panic(err)
	}
	if err := os.WriteFile(outputPath, data, 0o644); err != nil {
		panic(err)
	}
	fmt.Println("Wrote " + outputPath)
}

func getenv(name string, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}
