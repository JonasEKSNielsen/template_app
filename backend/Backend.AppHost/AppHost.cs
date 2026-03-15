var builder = DistributedApplication.CreateBuilder(args);

var api = builder.AddProject<Projects.API>("api");

var flutter = builder.AddFlutterApp("template-app", "../../template_app")
	.WithArgs("-d", "web-server")
	.WithDartDefine("APP_ENV", "local")
	.WithDartDefine("API_URL_HTTP", api.GetEndpoint("http"))
	.WithDartDefine("API_URL_HTTPS", api.GetEndpoint("https"))
	.WithReference(api);

api.WithEnvironment("FrontendUrl", flutter.GetEndpoint("http"));

builder.Build().Run();
