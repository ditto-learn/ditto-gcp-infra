environment              = "test"
gcp_project_id           = "my-gcp-project-test"
supabase_organization_id = "my-org-slug"
supabase_project_name    = "ditto-learn-test"
supabase_region          = "eu-west-2"

site_url = "https://test.example.ditto-learn.com"
additional_redirect_urls = [
  "https://test.example.ditto-learn.com/auth/callback"
]

supabase_max_rows                 = 1000
supabase_additional_allowed_cidrs = []

ai_image                   = "europe-west2-docker.pkg.dev/my-gcp-project-test/backend-images/ditto-ai-engine:latest"
learning_image             = "europe-west2-docker.pkg.dev/my-gcp-project-test/backend-images/ditto-learning-engine:latest"
question_image             = "europe-west2-docker.pkg.dev/my-gcp-project-test/backend-images/ditto-question-engine:latest"

vercel_oidc = {
  workload_identity_pool_id          = "vercel-test-pool"
  workload_identity_pool_provider_id = "vercel-test-provider"
  issuer_mode                        = "team"
  team_slug                          = "your-vercel-team-slug"
  allowed_audiences                  = ["https://vercel.com/your-vercel-team-slug"]
  allowed_subjects = [
    "owner:team:your-vercel-team-slug:project:ditto-learn-test:environment:preview",
  ]
}

cors_origins = {
  ai       = ["https://app.example.ditto-learn.com"]
  learning = ["https://app.example.ditto-learn.com"]
  question = ["https://app.example.ditto-learn.com"]
}

content_bucket_name_override = null
