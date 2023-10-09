resource "grafana_folder" "decentrifi" {
  title = "Decentrifi Dashboards"
}

resource "grafana_dashboard" "decentrifi-usage" {
  overwrite = true
  config_json = file("grafana/dashboards/decentrifi-usage.json")
  folder      = grafana_folder.decentrifi.id
  depends_on  = [grafana_folder.decentrifi]
}