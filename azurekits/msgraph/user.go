package msgraph

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"
)

type UsersResp struct {
	OdataContext  string `json:"@odata.context"`
	OdataNextLink string `json:"@odata.nextLink"`
	Users         Users  `json:"value"`
}

type Users []User

type User struct {
	ID                string `json:"id"`
	DisplayName       string `json:"displayName"`
	UserPrincipalName string `json:"userPrincipalName"`
}

func (c *Client) GetUsers(ctx context.Context) (Users, error) {
	users := Users{}
	nextLink := "https://graph.microsoft.com/v1.0/users"

	for {
		req, err := http.NewRequestWithContext(ctx, "GET", nextLink, nil)
		if err != nil {
			return Users{}, err
		}

		req.Header.Set("Authorization", "Bearer "+c.token)

		resp, err := c.httpClient.Do(req)
		if err != nil {
			return Users{}, err
		}
		defer resp.Body.Close()

		byteArray, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return Users{}, err
		}

		if resp.StatusCode != http.StatusOK {
			return Users{}, fmt.Errorf("GET /users failed (%d)", resp.StatusCode)
		}

		var ur UsersResp
		if err := json.Unmarshal(byteArray, &ur); err != nil {
			return nil, err
		}

		users = append(users, ur.Users...)

		if len(ur.OdataNextLink) > 0 {
			nextLink = ur.OdataNextLink
			continue
		}

		break
	}

	return users, nil
}

type UserAuthenticationMethodsResp struct {
	UserAuthenticationMethods UserAuthenticationMethods `json:"value"`

	OdataContext  string `json:"@odata.context"`
	OdataNextLink string `json:"@odata.nextLink"`
}

type UserAuthenticationMethods []UserAuthenticationMethod

type UserAuthenticationMethod struct {
	ID              string    `json:"id"`
	DisplayName     string    `json:"displayName,omitempty"`
	PhoneNumber     string    `json:"phoneNumber,omitempty"`
	CreatedDateTime time.Time `json:"createdDateTime"`

	OdataType string `json:"@odata.type"`
}

func (c *Client) GetUserAuthenticationMethod(ctx context.Context, userId string) (UserAuthenticationMethods, error) {
	uams := UserAuthenticationMethods{}
	url := "https://graph.microsoft.com/beta/users/" + userId + "/authentication/methods"

	for {
		req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
		if err != nil {
			return UserAuthenticationMethods{}, err
		}

		req.Header.Set("Authorization", "Bearer "+c.token)

		resp, err := c.httpClient.Do(req)
		if err != nil {
			return UserAuthenticationMethods{}, err
		}
		defer resp.Body.Close()

		byteArray, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return UserAuthenticationMethods{}, err
		}

		if resp.StatusCode != http.StatusOK {
			return UserAuthenticationMethods{}, fmt.Errorf("GET /users/%s/authentication/methods failed (%d)", userId, resp.StatusCode)
		}

		var uamr UserAuthenticationMethodsResp
		if err := json.Unmarshal(byteArray, &uamr); err != nil {
			return UserAuthenticationMethods{}, err
		}

		uams = append(uams, uamr.UserAuthenticationMethods...)

		if len(uamr.OdataNextLink) > 0 {
			url = uamr.OdataNextLink
			continue
		}
		break
	}

	return uams, nil
}
