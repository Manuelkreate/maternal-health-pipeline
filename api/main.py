from fastapi import FastAPI #type: ignore
from api.routers import conflict_vs_health
from api.routers import delivery_outcomes
from api.routers import health_profiles
from api.routers import health_spending
from api.routers import state_rankings
from api.routers import wealth_delivery

app = FastAPI(title="Nigeria Maternal Health API")

app.include_router(conflict_vs_health.router, tags=['State Health'])

app.include_router(delivery_outcomes.router, tags=['State Health'])

app.include_router(health_profiles.router, tags=['State Health'])

app.include_router(health_spending.router, tags=['Country Expenditure'])

app.include_router(state_rankings.router, tags=['State Health'])

app.include_router(wealth_delivery.router, tags=['State Health'])

@app.get('/')
async def root():
    return {'status': 'Nigeria Maternal Health API is running'}
