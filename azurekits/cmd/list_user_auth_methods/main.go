package main

import (
	"context"
	"flag"
	"fmt"

	"github.com/s-tajima/clikits/azurekits/msgraph"
)

func main() {
	tenant := flag.String("tenant", "", "tenant")
	clientID := flag.String("client-id", "", "clientID")
	clientSecret := flag.String("client-secret", "", "clientSecret")
	flag.Parse()

	ctx := context.Background()

	client, err := msgraph.New(ctx, *tenant, *clientID, *clientSecret)

	if err != nil {
		fmt.Println(err)
		return
	}

	users, err := client.GetUsers(ctx)
	if err != nil {
		fmt.Println(err)
		return
	}

	for _, u := range users {
		uams, _ := client.GetUserAuthenticationMethod(ctx, u.ID)

		for _, uam := range uams {
			fmt.Printf("%s\t%s\t%s\t%s\n", u.UserPrincipalName, uam.OdataType, uam.DisplayName, uam.PhoneNumber)
		}
	}
}
