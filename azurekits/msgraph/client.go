package msgraph

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"net/http"
	"net/url"
	"strings"
)

type AuthResponse struct {
	Token   string `json:"access_token"`
	Expires int    `json:"expires_in"`
}

type Client struct {
	httpClient   *http.Client
	tenant       string
	clientID     string
	clientSecret string
	token        string

	endpoint string
}

func New(ctx context.Context, tenant string, clientID string, clientSecret string) (*Client, error) {
	c := &Client{
		httpClient:   new(http.Client),
		tenant:       tenant,
		clientID:     clientID,
		clientSecret: clientSecret,
	}

	err := c.GetToken(ctx)
	if err != nil {
		return &Client{}, err
	}

	return c, nil
}

func (c *Client) GetToken(ctx context.Context) error {
	values := url.Values{}
	values.Set("client_id", c.clientID)
	values.Add("client_secret", c.clientSecret)
	values.Add("scope", "https://graph.microsoft.com/.default")
	values.Add("grant_type", "client_credentials")

	req, err := http.NewRequestWithContext(ctx, "POST", "https://login.microsoftonline.com/"+c.tenant+"/oauth2/v2.0/token", strings.NewReader(values.Encode()))
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	byteArray, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	if resp.StatusCode != http.StatusOK {
		return err
	}

	var authResponse AuthResponse
	if err := json.Unmarshal(byteArray, &authResponse); err != nil {
		return err
	}

	c.token = authResponse.Token
	return nil
}
