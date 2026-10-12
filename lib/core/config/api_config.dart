String resolveApiUrl() {
  const env = String.fromEnvironment('API_URL');
  if (env.isNotEmpty) return env;
  return 'http://72.62.199.225';
}
