using-VK-API

=====================================================

That app illustrates how to create application for VK API (client-server API). Here are used OAuth authorization, AFNetworking and GET/POST requests for VK API.

The app has 1 screen showing a wall of the user registered via OAuth authorization. Wall screen shows all posts of that user in a dynamic table via custom cell for illustrating all necessary information. When you press on one of them you go to a post’s profile screen to see and edit its information (add/delete like for post and add comment). At the top of the wall is a textfield for adding a new post.

During my app’s realization I touched the following topics:

- basics of client-server API;
- basics of OAuth authorization;
- how to use AFNetworking;
- how to use VK API;
- creating custom UIButtons;
- creating custom tableView in code;
- creating custom singleton;
- creating custom cell.

Key features of the app: 

1. using basics of client-server API (OAuth authorization, AFNetworking and GET/POST requests for VK API);
2. using different ways to draw views for custom cell (by code or by storyboard).